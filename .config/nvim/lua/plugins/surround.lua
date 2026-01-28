---@module "lazy"
---@type LazyPluginSpec[]
return {
  {
    "nvim-mini/mini.surround",
    opts = function(_, opts)
      if opts.mappings == nil then
        opts.mappings = {}
      end
      opts.mappings.add = "S"
    end,
  },
}
