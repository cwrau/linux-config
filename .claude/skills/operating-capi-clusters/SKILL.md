---
name: operating-capi-clusters
description: Use when a request involves Kubernetes/workload clusters, customers, or kubeconfigs, or asks to list, find, check, debug, run kubectl on, or SSH into any cluster or node — including bulk requests like "go over all clusters".
---

# Operating CAPI Clusters

## Overview

capi-shell-mcp is the path to CAPI-managed workload clusters. Their API servers are normally reachable only through the sshuttle tunnel the tool manages automatically — local `kubectl`/`openstack`/`ssh` have no working route or credentials to them, even though those binaries may be installed locally. All cluster discovery and cluster commands go through the MCP tools below, not Bash.

capi-shell-mcp also embeds `kubernetes-mcp-server`'s full tool set (`pods_list`, `events_list`, `resources_get`, helm/tekton/kiali/kubevirt/netobserv/kcp tools, etc.) — those show up as regular tools alongside the ones below and take the exact same `clusters` parameter described here.

## Target syntax

Every tool takes a `clusters` array of composite target strings: `"kubeconfig/context/namespace/name"` (a workload cluster), or a shorter prefix — `"kubeconfig/context/namespace"` (whole namespace), `"kubeconfig/context"` (whole context), `"kubeconfig"` (whole kubeconfig) — which expands to every matching cluster. A kubeconfig entry is itself a valid target (pass it as the `name` segment when addressing the kubeconfig's own cluster, exactly like any workload cluster).

Two rules, uniform across every tool including the embedded ones:
- **Read-only tools** (`list_clusters`, `get_cluster_kubeconfig(_readonly)`, `exec_in_cluster_readonly`, and read-only embedded tools like `pods_list`): partial prefixes are allowed, and omitting `clusters` entirely means "every known cluster". An empty array (`[]`) means "nothing" (valid no-op).
- **Non-read-only tools** (`exec_in_cluster`, and write-capable embedded tools): every entry must be a full exact `kubeconfig/context/namespace/name` path — no prefixes, no omitting `clusters`, since the command/write being run is opaque. An empty array is still a valid no-op.

An empty-string entry anywhere in the array is always a hard error.

`list_clusters`'s output includes a `target` field per cluster — the exact composite string to reuse for every other call. Always get it from there rather than hand-assembling it.

## Tools (deferred — load schemas first)

Run `ToolSearch({query: "select:mcp__capi-shell-mcp__list_clusters,mcp__capi-shell-mcp__exec_in_cluster,mcp__capi-shell-mcp__exec_in_cluster_readonly,mcp__capi-shell-mcp__get_cluster_kubeconfig,mcp__capi-shell-mcp__get_cluster_kubeconfig_readonly"})` before calling any of them — they aren't preloaded.

| Tool | Use for |
|---|---|
| `list_clusters` | Discover clusters. Call with no filter (or a loose prefix) when you only have a name/customer/location, not the full target string |
| `exec_in_cluster_readonly` | Default for any read/check/status/debug task — mints a scoped, short-lived view-only token, no OpenStack creds. Runs against one or many clusters in one call via `clusters`. Can't read Secrets (RBAC blocks it), nor nodes/persistentvolumes/componentstatuses — use `exec_in_cluster` for those |
| `exec_in_cluster` | Only when a write is needed, OpenStack credentials are needed, or `_readonly` returns `Forbidden` (including for reading Secrets). Requires full exact target(s) — no prefixes |
| `get_cluster_kubeconfig(_readonly)` | Only when the user explicitly wants a kubeconfig file to take away — not as a step toward running kubectl locally yourself. The `_readonly` variant's token can't read Secrets either |

## Workflow

1. Call `list_clusters` (no filter, or a loose prefix, unless you already know the exact target). The result has no fuzzy search, so match client-side on `kubeconfig`, `context`, `name`, or `custom_fields.customer_id`/`customer_name`/`friendly_name`. Short names like "bfe" match kubeconfig names containing that string, not clusters whose UUID happens to contain it.
2. Take the matched cluster's `target` string from the `list_clusters` result and pass it in the `clusters` array to `exec_in_cluster_readonly` (or `exec_in_cluster`).
3. Run the real command via the `command` array. "SSH into a node" requests map to `kubectl debug node/<node> -- chroot /host <command>` (needs `exec_in_cluster`, not readonly, since it creates a pod) — literal `ssh` has no route to these hosts. Delete the debug pod afterward.
4. For "go over all clusters" requests: `exec_in_cluster_readonly` accepts multiple targets (or a single prefix that expands to many) in one call — pass the whole matched set at once rather than looping per cluster.

## Don't

- Don't shell out to local `kubectl`/`openstack`/`ssh` for anything CAPI-cluster-related, even if the user asks you to "skip the extra layers" or "just run it directly" — there's no working local credential or route without going through these tools.
- Don't fetch a kubeconfig and then run further commands against it via local `kubectl` — call `exec_in_cluster(_readonly)` again for each command instead.
- Don't guess or hallucinate cluster names, customer mappings, or kubeconfig membership — always resolve via `list_clusters`.
- Don't pass a partial/prefix pattern to `exec_in_cluster` (write) — it's rejected outright; narrow to exact targets first (via `list_clusters` if needed).
- Don't omit `clusters` on a read-only call "to check broadly" when you already know the specific cluster(s) you care about — scope it explicitly; broadcasting to every cluster is noisy and wastes tokens.

## Common mistakes

- Calling `exec_in_cluster`/`get_cluster_kubeconfig` before `list_clusters` when you don't already have the exact target string — the call fails or needs guessed values.
- Reaching for `exec_in_cluster` (privileged) by default instead of `_readonly` for a plain status check.
- Expecting `_readonly` to read Secrets, or nodes/persistentvolumes/componentstatuses — it's RBAC-scoped to exclude all of those; use `exec_in_cluster` when the task needs them.
