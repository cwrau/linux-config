---@type LazyPlugin[]
local plugins = {
  {
    "tpope/vim-fugitive",
    lazy = false,
  },
  {
    "petertriho/cmp-git",
    config = function()
      require("cmp_git").setup({
        gitlab = {
          hosts = { "gitlab.teuto.net", "tickets.teuto.net" },
        },
      })
    end,
  },
}

return plugins
