---@module "lazy"
---@type LazyPluginSpec[]
return {
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
