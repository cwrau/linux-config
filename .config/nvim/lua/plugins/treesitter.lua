---@type LazyPlugin[]
local plugins = {
  {
    "nvim-treesitter/nvim-treesitter",
    ---@param opts TSConfig
    opts = function(_, opts)
      opts.ignore_install = { "help" }
      opts.ensure_installed = "all"
      if opts.indent == nil then
        opts.indent = {}
      end
      if opts.indent.disable == nil then
        opts.indent.disable = {}
      end
      vim.list_extend(opts.indent.disable, {
        "yaml",
      })
    end,
  },
}

return plugins
