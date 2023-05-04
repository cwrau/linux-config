-- every spec file under config.plugins will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins
return {
  -- add jsonls and schemastore ans setup treesitter for json, json5 and jsonc
  ---@class PluginLspOpts
  { import = "lazyvim.plugins.extras.lang.json" },
}
