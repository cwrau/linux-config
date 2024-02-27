---@type LazyPlugin[]
local plugins = {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        sh = { "shellcheck" }
      }
    },
  },
}

return plugins
