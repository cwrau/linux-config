local plugins = {
  {
    "neovim/nvim-lspconfig",
    opts = {
      ---@module "lspconfig.configs"
      ---@type table<string, lspconfig.Config>
      servers = {
        bashls = {
          on_attach = function(client)
            client.settings = vim.tbl_deep_extend("force", client.settings, { bashIde = { shellcheckPath = "" } })
            client.notify("workspace/didChangeConfiguration", { settings = client.settings })
          end,
        },
        yamlls = {
          before_init = function(_, config)
            vim.tbl_deep_extend("force", config, { settings = { yaml = { keyOrdering = false } } })
          end,
        },
        ["systemd-language-server"] = {},
      },
      setup = {
        ["systemd-language-server"] = function(_, _)
          require("lspconfig.configs")["systemd-language-server"] = {
            default_config = {
              cmd = { "systemd-language-server" },
              filetypes = { "systemd" },
              root_dir = function(fname)
                return vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
              end,
              single_file_support = true,
            },
            docs = {
              description = [[
https://github.com/psacawa/systemd-language-server

`systemd-language-server` can be installed via `pip`:
```sh
pip install systemd-language-server
```

Language Server for Systemd unit files
]],
            },
          }
        end,
      },
    },
  },
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    config = true,
    lazy = false,
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
