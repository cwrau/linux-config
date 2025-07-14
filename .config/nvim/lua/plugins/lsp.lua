---@module "lazy"
---@type LazyPluginSpec[]
return {
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
    dependencies = { "neovim/nvim-lspconfig", "which-key.nvim" },
    ft = { "yaml" },
  },
}
