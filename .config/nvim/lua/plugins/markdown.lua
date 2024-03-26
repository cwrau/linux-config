---@type LazyPlugin[]
local plugins = {
  {
    "iamcco/markdown-preview.nvim",
    config = function()
      vim.g.mkdp_browser = "xdg-open"
    end,
  },
}

return plugins
