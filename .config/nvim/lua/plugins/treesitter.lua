---@module "lazy"
---@type LazyPluginSpec[]
return {
  {
    "nvim-treesitter/nvim-treesitter",
    ---@module "lazyvim"
    ---@module "nvim-treesitter.config"
    ---@param opts lazyvim.TSConfig | TSConfig
    opts = function(_, opts)
      opts.ensure_installed = { "all" }
    end,
  },
}
