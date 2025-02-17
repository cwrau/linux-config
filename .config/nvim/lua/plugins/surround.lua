local plugins = {
  {
    "echasnovski/mini.surround",
    opts = function(_, opts)
      if opts.mappings == nil then
        opts.mappings = {}
      end
      opts.mappings.add = "S"
    end,
  },
}

return plugins
