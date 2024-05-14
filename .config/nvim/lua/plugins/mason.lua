---@type LazyPlugin[]
local plugins = {
  {
    "williamboman/mason.nvim",
    lazy = false,
    priority = 500,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    priority = 250,
    ---@type MasonLspconfigSettings
    opts = {
      automatic_installation = true,
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    lazy = false,
    priority = 250,
    opts = {
      ensure_installed = {
        { "lua-language-server", version = "3.6.23" },
      },
    },
  },
  {
    "zapling/mason-conform.nvim",
    lazy = false,
    priority = 250,
    opts = {},
    dependencies = {
      "stevearc/conform.nvim",
    },
  },
  ---{
  ---  "RubixDev/mason-update-all",
  ---  dependencies = {
  ---    "williamboman/mason.nvim",
  ---  },
  ---  lazy = false,
  ---  priority = 400,
  ---  init = function()
  ---    require("mason-update-all").update_all()
  ---  end,
  ---},
}

return plugins
