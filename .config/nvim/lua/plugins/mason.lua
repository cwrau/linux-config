---@module "lazy"
---@type LazyPluginSpec[]
return {
  {
    "mason-org/mason.nvim",
    lazy = false,
    priority = 500,
    ---@module "mason"
    ---@type MasonSettings
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    ---@module "mason-lspconfig"
    ---@type MasonLspconfigSettings
    opts = {
      automatic_installation = true,
    },
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
    lazy = false,
  },
  {
    "rshkarin/mason-nvim-lint",
    lazy = false,
    priority = 250,
    ---@module "mason-nvim-lint"
    ---@type MasonNvimLintSettings
    opts = {
      ensure_installed = {},
      ignore_install = {},
      automatic_installation = true,
      quiet_mode = true,
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
  {
    "RubixDev/mason-update-all",
    dependencies = {
      "mason-org/mason.nvim",
    },
    lazy = false,
    priority = 400,
    ---@module "mason-update-all"
    ---@type MasonUpdateAllSettings
    opts = {
      show_no_updates_notification = false,
    },
    init = function()
      require("mason-update-all").update_all()
    end,
  },
}
