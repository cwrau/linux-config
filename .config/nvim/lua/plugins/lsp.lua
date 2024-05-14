---@type LazyPlugin[]
local plugins = {
  {
    "neovim/nvim-lspconfig",
    ---@type PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        yamlls = {
          before_init = function(_, config)
            if config.settings == nil then
              config.settings = {}
            end
            if config.settings.yaml == nil then
              config.settings.yaml = {}
            end
            config.settings.yaml.keyOrdering = false
          end,
        },
      },
    },
  },
  {
    dir = vim.fn.stdpath("config") .. "/lua/utils/yaml-schema-detect.nvim",
    dependencies = { "neovim/nvim-lspconfig", "which-key.nvim" },
    config = true,
    ft = { "yaml" },
  },
}

return plugins
