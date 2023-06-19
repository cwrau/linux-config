---@type LazyPlugin[]
local plugins = {
  {
    "jay-babu/mason-null-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "jose-elias-alvarez/null-ls.nvim",
    },
    config = function()
      require("mason-null-ls").setup({
        automatic_installation = true
      })
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    -- opts will be merged with the parent spec
    opts = function()
      local null_ls = require("null-ls")

      local sources = {
        null_ls.builtins.formatting.shfmt.with({
          extra_args = { "-i", "2", "-ci" },
        }),
        null_ls.builtins.formatting.beautysh.with({
          extra_args = { "-i", "2", "--force-function-style", "fnpar" },
          disabled_filetypes = { "sh", "bash" },
        }),
        null_ls.builtins.diagnostics.yamllint.with({
          disabled_filetypes = { "helm" },
        }),
      }

      local tools = {
        diagnostics = {
          "actionlint",
          "flake8",
          "jsonlint",
          "luacheck",
          "markdownlint",
          "revive",
          "shellcheck",
          "todo_comments",
          "zsh",
        },
        formatting = {
          "black",
          "isort",
          "prettier",
          "rustfmt"
        },
        code_actions = {
          "refactoring",
          "shellcheck",
        },
      }

      for type, type_sources in pairs(tools) do
        for _, source in pairs(type_sources) do
          table.insert(sources, null_ls.builtins[type][source])
        end
      end

      return {
        sources = sources,
      }
    end,
  },
}

return plugins
