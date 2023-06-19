---@type LazyPlugin[]
local plugins = {
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
      "simrat39/rust-tools.nvim"
    }
  },
  {
    "simrat39/rust-tools.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-lua/plenary.nvim",
      "Saecki/crates.nvim",
      "williamboman/mason.nvim",
    },
    opts = {
      dap = {
        adapter = {
          type = 'server',
          port = "${port}",
          executable = {
            command = function()
              return require("mason-registry").get_package("codelldb"):get_install_path()
            end,
            args = {
              '--port',
              '${port}'
            }
          }
        }
      },
      tools = {
        hover_actions = {
          auto_focus = true
        }
      }
    },
    ft = { 'rust' },
    keys = {
      { '<leader>co', '<cmd>RustHoverActions<cr>', desc = "Hover Actions (Rust)" },
    },
    config = function(_, opts)
      require("rust-tools").setup(opts)
    end
  }
}

return plugins
