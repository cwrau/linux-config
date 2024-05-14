---@type LazyPlugin[]
local plugins = {
  ---{
  ---  "nvim-neo-tree/neo-tree.nvim",
  ---  opts = {
  ---    event_handlers = {
  ---      {
  ---        event = "file_opened",
  ---        handler = function(_)
  ---          require("neo-tree.command").execute({ action = "close" })
  ---        end,
  ---      },
  ---    },
  ---  },
  ---},
  {
    dir = vim.fn.stdpath("config") .. "/lua/utils/copy-github-url.nvim",
    dependencies = { "which-key.nvim" },
    config = true,
    lazy = false,
  },
}

return plugins
