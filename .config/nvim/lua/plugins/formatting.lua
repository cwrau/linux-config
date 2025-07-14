---@module "lazy"
---@type LazyPluginSpec[]
return {
  {
    "stevearc/conform.nvim",
    lazy = false,
    dependencies = {
      "mason-org/mason.nvim",
    },
    ---@module "conform"
    ---@type conform.setupOpts
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
        ---yaml = { "yamlfix" },
        json = { "fixjson" },
        ["*"] = { "trim_whitespace", "trim_newlines" },
      },
    },
  },
}
