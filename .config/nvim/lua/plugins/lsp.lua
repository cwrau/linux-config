---@type LazyPlugin[]
local plugins = {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "towolf/vim-helm",
    },
    ---@type PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        helm_ls = {},
        pyright = {
          before_init = function(_, config)
            local utils = require("utils.python")
            config.settings.python.pythonPath = utils.get_python_path(config.root_dir)
          end,
        },
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
          on_attach = function()
            require("utils.yaml-schema-select").setup()
          end
        },
        rust_analyzer = {
          settings = {
            ['rust-analyzer'] = {
              cargo = {
                features = "all"
              }
            }
          }
        },
        gopls = {}
      },
    },
    init = function()
      local keys = require("lazyvim.plugins.lsp.keymaps")
      keys[#keys + 1] = { "=", "vim.lsp.buf.format" }
    end
  }
}

return plugins
