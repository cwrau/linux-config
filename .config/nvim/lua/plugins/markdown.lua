---@type LazyPlugin[]
local plugins = {
  {
    "iamcco/markdown-preview.nvim",
    ft = { "markdown" },
    config = function()
      vim.g.mkdp_browser = 'xdg-open'
    end,
    build = function()
      vim.fn['mkdp#util#install']()
    end
  }
}

return plugins
