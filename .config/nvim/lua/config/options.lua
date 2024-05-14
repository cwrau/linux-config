-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local XDG_CACHE_HOME = vim.env.XDG_CACHE_HOME

vim.opt.backupdir = XDG_CACHE_HOME .. "/nvim/backupdir"
vim.opt.clipboard:append({ "unnamed", "unnamedplus" })
vim.opt.directory = XDG_CACHE_HOME .. "/nvim/swapdir"

vim.opt.mouse = {}
vim.opt.softtabstop = 0
vim.opt.relativenumber = true
vim.opt.spelllang = { "en_gb", "de_de" }
vim.opt.wrap = true
