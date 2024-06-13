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
    "cwrau/copy-github-url.nvim",
    dev = true,
    dependencies = { "which-key.nvim" },
    config = true,
    lazy = false,
  },
  {
    "deponian/nvim-base64",
    dependencies = { "which-key.nvim" },
    config = function()
      require("nvim-base64").setup()
      require("which-key").register({
        c = {
          b = {
            name = "Base64",
            b = { "<Plug>(ToBase64)", "Encode to Base64" },
            d = { "<Plug>(FromBase64)", "Decode Base64" },
          },
        },
      }, { prefix = "<leader>", mode = "x" })
    end,
  },
  {
    "voxelprismatic/rabbit.nvim",
    config = true,
  },
}

return plugins
