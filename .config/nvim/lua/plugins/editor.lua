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
  },
  {
    "deponian/nvim-base64",
    dependencies = { "which-key.nvim" },
    config = function()
      require("nvim-base64").setup()
      require("which-key").add({
        {
          mode = { "x" },
          { "<leader>cb", group = "Base64" },
          { "<leader>cbb", "<Plug>(ToBase64)", desc = "Encode to Base64" },
          { "<leader>cbd", "<Plug>(FromBase64)", desc = "Decode from Base64" },
        },
      })
    end,
  },
  {
    "voxelprismatic/rabbit.nvim",
    config = true,
  },
}

return plugins
