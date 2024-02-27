---@type LazyPlugin[]
local plugins = {
  {
    "stevearc/conform.nvim",
    dependencies = {
      "williamboman/mason.nvim",
    },
    ---@type ConformOpts
    opts = {
      formatters = {
        shfmt = {
          prepend_args = { "-i", "2", "-ci" },
        },
        beautysh = {
          prepend_args = { "-i", "2", "--force-function-style", "fnpar" },
        },
      },
      formatters_by_ft = {
        helm = {},
        yaml = { "yamlfmt" },
        json = { "fixjson" },
        ["*"] = { "trim_whitespace", "trim_newlines", "codespell" },
      },
    },
  },
}

return plugins
