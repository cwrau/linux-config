--local configs = require('lspconfig.configs')
--local util = require('lspconfig.util')
--
--if not configs.helm_ls then
--  configs.helm_ls = {
--    default_config = {
--      cmd = {"helm_ls", "serve"},
--      filetypes = {'helm'},
--      root_dir = function(fname)
--        return util.root_pattern('Chart.yaml')(fname)
--      end,
--    },
--  }
--end

return {
  -- add pyright to lspconfig
  {
    "neovim/nvim-lspconfig",
    dependencies = { "towolf/vim-helm" },
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        helm_ls = {},
        -- pyright will be automatically installed with mason and loaded with lspconfig
        pyright = {
          before_init = function(_, config)
            local utils = require("utils.python")
            config.settings.python.pythonPath = utils.get_python_path(config.root_dir)
          end,
        },
      },
    },
  },
}
