local plugins = {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = {
        filesystem = {
          filtered_items = {
            hide_gitignored = false,
          },
        },
      },
    },
  },
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
  {
    "folke/snacks.nvim",
    ---@module 'snacks'
    ---@type snacks.Config
    opts = {
      indent = {
        enable = true,
      },
      dim = {
        scope = {
          siblings = true,
        },
      },
    },
  },
}

return plugins
