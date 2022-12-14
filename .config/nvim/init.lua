local XDG_CACHE_HOME = vim.env.XDG_CACHE_HOME

vim.opt.runtimepath:append '/usr/share/vim/vimfiles'

vim.opt.backup = true
vim.opt.backupdir = XDG_CACHE_HOME .. '/nvim/backupdir'
vim.opt.clipboard:append { 'unnamed', 'unnamedplus' }
vim.opt.directory = XDG_CACHE_HOME .. '/nvim/swapdir'
vim.opt.expandtab = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.inccommand = 'nosplit'
vim.opt.incsearch = true
vim.opt.modeline = true
vim.opt.modelines = 5
vim.opt.mouse = ''
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.shiftwidth = 2
vim.opt.smartcase = true
vim.opt.smartcase = true
vim.opt.softtabstop = 0
vim.opt.swapfile = true
vim.opt.tabstop = 2
vim.opt.termguicolors = true
vim.opt.undodir = XDG_CACHE_HOME .. '/nvim/undodir'
vim.opt.undofile = true
vim.opt.wrap = false

require('plugins')

-- fuzzy finding with vim
vim.opt.path:append '**'
-- Enable autocompletion:
vim.opt.wildmode = { 'longest', 'list', 'full' }
-- Spell-check set to <leader>o, 'o' for 'orthography':
vim.opt.spelllang = { 'de', 'en' }
vim.opt.spellsuggest = { 'best', 9 }
local spellFilesGroup = vim.api.nvim_create_augroup('spellFiles', {})
vim.api.nvim_create_autocmd('FileType', { pattern = 'markdown', command = 'setlocal spell', group = spellFilesGroup })
vim.api.nvim_create_autocmd('FileType',
  { pattern = 'markdown', command = 'setlocal textwidth=90', group = spellFilesGroup })

-- preferences
-- Stay in visual mode when indenting. You will never have to run gv after
-- performing an indentation.
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

vim.opt.wildignore:append({ '*/tmp/*', '*.so', '*.swp', '*.zip', '*.pyc', '*.db', '*.sqlite' })

-- jsx
vim.g.jsx_ext_required = 0
vim.opt.guicursor = ''

vim.api.nvim_set_hl(0, 'ExtraWhitespace',
  { ctermfg = 167, fg = '#CC6666', ctermbg = 167, bg = '#CC6666', underdashed = true })
vim.api.nvim_create_autocmd('InsertEnter', { command = 'match ExtraWhitespace /\\s\\+\\%#\\@<!$/' })
vim.api.nvim_create_autocmd('InsertLeave', { command = 'match ExtraWhitespace /\\s\\+$/' })
vim.cmd.match('ExtraWhitespace /\\s\\+$/') -- TODO
vim.api.nvim_create_autocmd('BufWrite', { command = ':%s/\\s\\+$//e' })

vim.diagnostic.config {
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = true,
  severity_sort = true,
}
