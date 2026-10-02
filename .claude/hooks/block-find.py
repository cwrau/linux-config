#!/usr/bin/env python3
"""PreToolUse hook: block `find` invocations in Bash tool calls, and block
scoped-search tools (`fd`, `rg`, recursive `grep`) from targeting the
filesystem root (`/`). Two related CLAUDE.md hard rules, both repeatedly
violated: "File finding: always fd, never find" and "never scope an
investigation to the whole filesystem (e.g. `find /`)." Any other absolute
path (`/etc`, `/var/log`, etc.) is fine -- only literal `/` is a whole-
filesystem search.

Walks a real bash AST (bashlex, a Python port of bash's own parser)
instead of hand-rolled token-splitting. Earlier versions used `shlex`
(a tokenizer, not a parser) with hand-coded rules for where one command
ends and another begins -- that missed redirect targets being mistaken
for search paths, and missed newlines as statement separators in
multi-line scripts. bashlex gives redirects, pipelines, command lists,
subshells, loops, and command/process substitution as distinct node
types, so this class of bug can't recur by construction. On anything
bashlex can't parse, fail open (allow) -- never block a real operation
because of a hook/parser limitation.
"""

import json
import os
import sys

import bashlex
import bashlex.errors

# Tools whose recursive-search path arguments may not be the filesystem root.
SCOPED_SEARCH_TOOLS = {"fd", "rg", "grep"}

# Attributes that hold child nodes, across the node kinds bashlex uses:
# command/pipeline/list/for/if/word -> .parts, compound -> .list plus its
# own .redirects, command/process substitution -> .command (singular).
LIST_CHILD_ATTRS = ("parts", "list", "redirects")
NODE_CHILD_ATTRS = ("command",)

HOME = os.path.expanduser("~")


def iter_commands(node):
    """Yield every `command` node anywhere in the tree: inside pipelines,
    `&&`/`||`/`;` lists, subshells, loops, conditionals, and command/process
    substitutions nested inside a word (e.g. `rg pattern $(find /)`)."""
    if node is None:
        return
    if node.kind == "command":
        yield node
    for attr in LIST_CHILD_ATTRS:
        for child in getattr(node, attr, None) or []:
            yield from iter_commands(child)
    for attr in NODE_CHILD_ATTRS:
        child = getattr(node, attr, None)
        if child is not None:
            yield from iter_commands(child)


def command_words(cmd_node):
    """Word nodes belonging to a command, in order. Deliberately excludes
    `assignment` parts (env-var prefixes like `FOO=bar`) and `redirect`
    parts (`2>/dev/null` etc.) -- bashlex already types those distinctly,
    so a redirect target can never be mistaken for a search-path argument
    here, unlike the old token-position heuristic."""
    return [p for p in cmd_node.parts if p.kind == "word"]


def is_recursive_grep(arg_words):
    for w in arg_words:
        tok = w.word
        if tok in ("-r", "-R", "--recursive"):
            return True
        if tok.startswith("--recursive="):
            return True
        if (
            tok.startswith("-")
            and not tok.startswith("--")
            and ("r" in tok[1:] or "R" in tok[1:])
        ):
            return True
    return False


def looks_like_path(tok: str) -> bool:
    return tok.startswith("/") or tok.startswith("~") or tok.startswith(".")


# rg/grep flags that supply the search pattern as a flag *value* instead of
# the usual leading positional -- when present, there is no positional
# pattern to protect, so every remaining positional is a genuine path.
PATTERN_VALUE_FLAGS = ("-e", "--regexp", "-f", "--file")


def path_candidate_words(base: str, arg_words):
    """Return only the arg words that are genuinely candidate path
    arguments for a scoped-search tool, excluding the leading PATTERN
    positional these tools all take before their path(s): `rg PATTERN
    [PATH...]`, `grep PATTERN [FILE...]`, `fd [PATTERN] [PATH...]`. Without
    this, a regex pattern that happens to start with `/`, `~`, or `.` --
    e.g. `rg -v '/linux-'` -- gets mistaken for an out-of-scope search path
    even though it was never a path at all (that example has no path
    argument whatsoever; it reads stdin from a pipe)."""
    has_pattern_flag = False
    skip_next = False
    positionals = []
    for w in arg_words:
        tok = w.word
        if skip_next:
            skip_next = False
            continue
        if tok in PATTERN_VALUE_FLAGS:
            has_pattern_flag = True
            skip_next = True  # the flag's own value is a pattern, not a path
            continue
        if any(tok.startswith(f + "=") for f in ("--regexp", "--file")):
            has_pattern_flag = True
            continue
        if tok.startswith("-"):
            continue  # some other flag -- best-effort skip, not a positional
        positionals.append(tok)

    if base in ("rg", "grep") and has_pattern_flag:
        return positionals  # no positional pattern expected; all are paths
    return positionals[1:]  # drop the leading PATTERN positional (rg/grep/fd all share this)


def disallowed_path(tok: str, cwd: str) -> bool:
    """Only the literal filesystem root is disallowed. Any other absolute
    (or relative-resolving-to-absolute) path is a legitimate scoped search,
    no matter where it lands -- the rule this enforces is "don't search the
    whole filesystem," not "stay under $HOME"."""
    expanded = os.path.expanduser(tok)
    if not os.path.isabs(expanded):
        expanded = os.path.join(cwd or HOME, expanded)
    normalized = os.path.normpath(expanded)
    return normalized == "/"


def find_violation(command: str, cwd: str):
    trees = bashlex.parse(command)

    for tree in trees:
        for cmd_node in iter_commands(tree):
            words = command_words(cmd_node)
            if not words:
                continue
            name = words[0].word
            base = name.rstrip("/").rsplit("/", 1)[-1]
            args = words[1:]

            if base == "find":
                return (
                    "Blocked: `find` invoked (any path -- /bin/find, "
                    "/usr/bin/find, ./find, etc. all match). CLAUDE.md hard "
                    "rule: always use `fd`, never `find`. Use `fd <pattern> "
                    "[path]` instead (e.g. `fd -td -i <name> ~/work "
                    "~/projects` to locate a repo, or `fd <dir>` to "
                    "list). If this is genuinely not a filesystem search "
                    "(e.g. a different tool literally named `find`), say "
                    "so and the rule can be adjusted."
                )

            if base in SCOPED_SEARCH_TOOLS:
                if base == "grep" and not is_recursive_grep(args):
                    continue
                for tok in path_candidate_words(base, args):
                    if not looks_like_path(tok):
                        continue
                    if disallowed_path(tok, cwd):
                        return (
                            f"Blocked: `{base}` targeting the filesystem "
                            f"root ({tok!r}). CLAUDE.md hard rule: never "
                            "scope an investigation to the whole "
                            "filesystem. Any other path is fine -- scope "
                            "the search to the actual repo/directory you "
                            "need instead."
                        )
    return None


def main():
    data = json.load(sys.stdin)
    if data.get("tool_name") != "Bash":
        return
    command = (data.get("tool_input") or {}).get("command", "")
    if not command:
        return
    cwd = data.get("cwd") or HOME

    try:
        message = find_violation(command, cwd)
    except bashlex.errors.ParsingError:
        # Can't parse it -> can't safely claim it's a violation. Allow.
        return

    if message:
        print(
            json.dumps(
                {
                    "hookSpecificOutput": {
                        "hookEventName": "PreToolUse",
                        "permissionDecision": "deny",
                    },
                    "systemMessage": message,
                }
            )
        )


if __name__ == "__main__":
    try:
        main()
    except Exception:
        # Never block a real operation because of a hook bug.
        pass
    sys.exit(0)
