---@type LazyPlugin[]
local plugins = {
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
    },
    ---@type MasonLspconfigSettings
    opts = {
      automatic_installation = true,
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    lazy = false,
    dependencies = {
      "williamboman/mason.nvim",
    },
    opts = {
      ensure_installed = {
        { "lua-language-server", version = "3.6.23" },
      },
    },
  },
  {
    "zapling/mason-conform.nvim",
    lazy = false,
    dependencies = {
      "williamboman/mason.nvim",
      "stevearc/conform.nvim",
    },
  },
}

return plugins
