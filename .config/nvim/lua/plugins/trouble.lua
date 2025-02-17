local plugins = {
  {
    "folke/trouble.nvim",
    -- opts will be merged with the parent spec
    ---@module "trouble.config"
    ---@type trouble.Config
    opts = {
      use_diagnostic_signs = true,
    },
  },
}

return plugins
