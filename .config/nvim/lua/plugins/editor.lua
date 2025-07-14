---@module "lazy"
---@type LazyPluginSpec[]
return {
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
  {
    "lucidph3nx/nvim-sops",
    keys = {
      { "<leader>cse", vim.cmd.SopsEncrypt, desc = "[E]ncrypt [F]ile" },
      { "<leader>csd", vim.cmd.SopsDecrypt, desc = "[D]ecrypt [F]ile" },
    },
  },
  ---{
  ---  "ramilito/winbar.nvim",
  ---  event = "BufReadPre",
  ---  dependencies = {
  ---    "nvim-tree/nvim-web-devicons",
  ---  },
  ---  config = function()
  ---    require("winbar").setup({
  ---      icons = true,
  ---      diagnostics = true,
  ---      buf_modified = true,
  ---      buf_modified_symbol = "M",
  ---      dim_inactive = {
  ---        enabled = false,
  ---        highlight = "WinbarNC",
  ---        icons = true, -- whether to dim the icons
  ---        name = true, -- whether to dim the name
  ---      },
  ---    })
  ---  end,
  ---},
}
