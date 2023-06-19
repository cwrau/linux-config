---@type LazyPlugin[]
local plugins = {
  {
    "echasnovski/mini.surround",
    event = "BufEnter",
    opts = function(_, opts)
      opts.mappings.add = 'S'
    end,
  },
}

return plugins
