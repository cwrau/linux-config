local shellcheckArgs = {
  "-x",
  "--format",
  "json",
  "-",
}

---@param input string
---@param pattern string
---@param instances table<string>
---@return boolean
local function matchesAnyPattern(input, pattern, instances)
  for _, instance in ipairs(instances) do
    local newPattern = pattern:gsub("_instance_", instance)
    if input:match(newPattern) then
      return true
    end
  end
  return false
end

---@param string string
---@return boolean
local function matchesUsedVars(string)
  local pkgbuildUsedVars = {
    "pkgbase",
    "pkgname",
    "pkgver",
    "pkgrel",
    "epoch",
    "pkgdesc",
    "arch",
    "url",
    "license",
    "groups",
    "depends",
    "optdepends",
    "makedepends",
    "checkdepends",
    "provides",
    "conflicts",
    "replaces",
    "backup",
    "options",
    "install",
    "changelog",
    "source",
    "noextract",
    "validpgpkeys",
    "md5sums",
    "sha1sums",
    "sha256sums",
    "sha224sums",
    "sha384sums",
    "sha512sums",
  }
  return matchesAnyPattern(string, "_instance_ appears unused.*", pkgbuildUsedVars)
end

---@param string string
---@return boolean
local function matchesProvidedVars(string)
  local pkgbuildProvidedVars = {
    "srcdir",
    "pkgdir",
    "startdir",
  }
  return matchesAnyPattern(string, "_instance_ is referenced but not assigned.*", pkgbuildProvidedVars)
end

local pkgbuildcheckExtraArgs = {
  "-s",
  "bash",
}

local pkgbuildcheckArgs = {}
vim.list_extend(pkgbuildcheckArgs, pkgbuildcheckExtraArgs)
vim.list_extend(pkgbuildcheckArgs, shellcheckArgs)

---@type LazyPlugin[]
local plugins = {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        sh = { "shellcheck" },
        PKGBUILD = { "pkgbuildcheck" },
      },
      linters = {
        shellcheck = {
          args = shellcheckArgs,
        },
        pkgbuildcheck = {
          cmd = "shellcheck",
          args = pkgbuildcheckArgs,
          stdin = true,
          ignore_exitcode = true,
          parser = function(output)
            ---@class DiagnosticItem
            ---@field code number
            ---@field message string
            ---@type DiagnosticItem[]
            local diagnostics = require("lint.linters.shellcheck").parser(output)
            local filteredDiagnostics = {}
            for _, item in ipairs(diagnostics or {}) do
              if item.code ~= 2164 and not matchesUsedVars(item.message) and not matchesProvidedVars(item.message) then
                table.insert(filteredDiagnostics, item)
              end
            end
            return filteredDiagnostics
          end,
        },
      },
    },
  },
}

return plugins
