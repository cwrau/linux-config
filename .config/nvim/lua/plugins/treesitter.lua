local plugins = {
  {
    "nvim-treesitter/nvim-treesitter",
    ---@module "nvim-treesitter.configs"
    ---@param opts TSConfig
    opts = function(_, opts)
      opts.ignore_install = { "help" }
      opts.ensure_installed = "all"
      if opts.modules == nil then
        opts.modules = { indent = { disable = { "yaml" } } }
      else
        opts.modules["indent"].disable = { "yaml" }
      end
    end,
  },
}

return plugins
