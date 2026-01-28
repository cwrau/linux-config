---@module "lazy"
---@type LazyPluginSpec[]
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        bashls = {
          on_attach = function(client)
            client.settings = vim.tbl_deep_extend("force", client.settings, { bashIde = { shellcheckPath = "" } })
            client.notify("workspace/didChangeConfiguration", { settings = client.settings })
          end,
        },
        yamlls = {
          settings = {
            yaml = {
              keyOrdering = false,
              schemaStore = {
                enable = true,
              },
            },
          },
        },
        nil_ls = {
          settings = {
            nix = {
              flake = {
                autoArchive = true,
              },
            },
          },
        },
        tofu_ls = {},
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
    ---@module "yaml-schema-detect"
    ---@type YamlSchemaDetectOptions
    opts = {},
    ft = { "yaml", "yaml.helm-values" },
  },
}
