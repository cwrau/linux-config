local plugins = {
  {
    "williamboman/mason.nvim",
    lazy = false,
    priority = 500,
    opts = {
      registries = {
        "file:~/projects/mason-registry",
      },
    },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    dev = true,
  },
  {
    "rshkarin/mason-nvim-lint",
    lazy = false,
    dev = true,
    priority = 250,
    opts = {
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
      "williamboman/mason.nvim",
    },
    lazy = false,
    dev = true,
    priority = 400,
    ---@module "mason-update-all"
    ---@type MasonUpdateAllSettings
    opts = {
      showNoUpdatesNotification = false,
    },
    init = function()
      require("mason-update-all").update_all()
    end,
  },
}

return plugins
