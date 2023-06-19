---@type LazyPlugin[]
local plugins = {
  {
    "folke/trouble.nvim",
    -- opts will be merged with the parent spec
    ---@type TroubleOptions
    opts = {
      use_diagnostic_signs = true,
    },
  },
}

return plugins
