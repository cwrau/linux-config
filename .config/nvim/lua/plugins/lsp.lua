---@module "lazy"
---@type LazyPlugin[]
local plugins = {
  {
    "neovim/nvim-lspconfig",
    ---@module "lazyvim"
    ---@type PluginLspOpts
    opts = {
      ---@module "lspconfig.configs"
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
    "cwrau/yaml-schema-detect.nvim",
    dev = true,
    config = true,
    dependencies = { "neovim/nvim-lspconfig", "which-key.nvim" },
    ft = { "yaml" },
  },
}

return plugins
