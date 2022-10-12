local XDG_CACHE_HOME = vim.env.XDG_CACHE_HOME
local XDG_DATA_HOME = vim.env.XDG_DATA_HOME

vim.opt.runtimepath:append '/usr/share/vim/vimfiles'

vim.call('plug#begin', XDG_DATA_HOME .. '/nvim/plugins')
local Plug = vim.fn['plug#']
Plug('Shougo/deoplete.nvim', { ['do'] = ':UpdateRemotePlugins' }) -- autocomplete
--Plug 'vim-syntastic/syntastic' " syntax check for most languages
Plug 'vim-airline/vim-airline' -- better monitoring
Plug 'mhinz/vim-signify'
Plug 'jiangmiao/auto-pairs' -- add eg. (->)
Plug 'kristijanhusak/vim-hybrid-material' -- Dark Theme
Plug 'tpope/vim-surround' -- Easy add matching parentheses
Plug('nvim-treesitter/nvim-treesitter', {['do'] = ':TSUpdate'})
Plug 'towolf/vim-helm'
Plug 'farmergreg/vim-lastplace'
Plug 'Chiel92/vim-autoformat'
vim.api.nvim_set_keymap('n', '=', ':Autoformat<CR>', {})
Plug 'christoomey/vim-system-copy'
Plug 'pgdouyon/vim-evanesco'
Plug 'mhinz/vim-startify'
Plug 'mechatroner/rainbow_csv'
Plug 'stevearc/vim-arduino'
Plug 'plasticboy/vim-markdown'
Plug 'sedm0784/vim-you-autocorrect'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'neovim/nvim-lspconfig'

--let g:syntastic_dockerfile_checkers = ['hadolint']
--let g:syntastic_yaml_checkers = ['yamllint']
--let g:syntastic_always_populate_loc_list = 1
--let g:syntastic_auto_jump = 1
--let g:syntastic_check_on_open = 1
--let g:syntastic_check_on_wq = 0

Plug('iamcco/markdown-preview.nvim', { ['do'] = vim.fn['mkdp#util#install'], ['for'] = {'markdown', 'vim-plug'}})
vim.g.mkdp_browser = 'google-chrome-stable'

--
--
--Plug 'neoclide/coc.nvim', {'branch': 'release'}
--inoremap <silent><expr> <TAB>
--      \ pumvisible() ? "\<C-n>" :
--      \ <SID>check_back_space() ? "\<TAB>" :
--      \ coc#refresh()
--inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
--
--function! s:check_back_space() abort
--  let col = col('.') - 1
--  return !col || getline('.')[col - 1]  =~# '\s'
--endfunction
--
--inoremap <silent><expr> <c-space> coc#refresh()
--inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
--
vim.call('plug#end')

vim.opt.backup = true
vim.opt.backupdir = XDG_CACHE_HOME .. '/nvim/backupdir'
vim.opt.directory = XDG_CACHE_HOME .. '/nvim/swapdir'
vim.opt.expandtab = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.inccommand = 'nosplit'
vim.opt.incsearch = true
vim.opt.modeline = true
vim.opt.modelines = 5
vim.opt.mouse = ''
vim.opt.wrap = false
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.shiftwidth = 2
vim.opt.smartcase = true
vim.opt.softtabstop = 0
vim.opt.swapfile = true
vim.opt.tabstop = 2
vim.opt.undodir = XDG_CACHE_HOME .. '/nvim/undodir'
vim.opt.undofile = true

-- fuzzy finding with vim
vim.opt.path:append '**'
-- Enable autocompletion:
vim.opt.wildmode = {'longest','list','full'}
-- Spell-check set to <leader>o, 'o' for 'orthography':
vim.opt.spelllang = {'de','en'}
vim.opt.spellsuggest = {'best',9}
local spellFilesGroup = vim.api.nvim_create_augroup('spellFiles', {})
vim.api.nvim_create_autocmd('FileType', { pattern = 'markdown', command = 'setlocal spell', group = spellFilesGroup })
vim.api.nvim_create_autocmd('FileType', { pattern = 'markdown', command = 'setlocal textwidth=90', group = spellFilesGroup })

-- preferences
-- j/k will move virtual lines (lines that wrap)
vim.api.nvim_set_keymap('n', 'j', '(v:count == 0 ? "gj" : "j")', {})
vim.api.nvim_set_keymap('n', 'k', '(v:count == 0 ? "gk" : "k")', {})
-- Stay in visual mode when indenting. You will never have to run gv after
-- performing an indentation.
vim.api.nvim_set_keymap('v', '<', '<gv', {})
vim.api.nvim_set_keymap('v', '>', '>gv', {})
-- Make Y yank everything from the cursor to the end of the line. This makes Y
-- act more like C or D because by default, Y yanks the current line (i.e. the
-- same as yy).
--noremap Y y$
-- navigate split screens easily
-- change spacing for language specific
--autocmd Filetype javascript setlocal ts=2 sts=2 sw=2

-- plugin settings

-- deoplete
vim.g['deoplete#enable_at_startup'] = true
vim.g.python3_host_prog = '/usr/bin/python'
-- use tab to forward cycle
--inoremap <silent><expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
-- use tab to backward cycle
--inoremap <silent><expr><s-tab> pumvisible() ? "\<c-p>" : "\<s-tab>"
-- Close the documentation window when completion is done
vim.api.nvim_create_autocmd({'InsertLeave', 'CompleteDone'}, { command = 'if pumvisible() == 0 | silent! pclose! | endif' })

-- Theme
vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1
vim.opt.termguicolors = true
vim.opt.background = 'dark'
vim.g.enable_bold_font = 1
vim.g.enable_italic_font = 1
vim.cmd.colorscheme('hybrid_material')

vim.opt.wildignore:append({'*/tmp/*', '*.so', '*.swp', '*.zip', '*.pyc', '*.db', '*.sqlite'})

-- jsx
vim.g.jsx_ext_required = 0
vim.opt.guicursor = ''

vim.g.arduino_dir = '/usr/share/arduino'

local arduinoStatusLine = function()
  local port = vim.call('arduino#GetPort')
  local line = '[' .. vim.g.arduino_board .. '] [' .. vim.g.arduino_programmer .. ']'
  if (port or '') == '' then
    line = line .. ' (' .. port .. ':' .. vim.g.arduino_serial_baud .. ')'
  end
  return line
end

local airlineInit = function()
  vim.g.airline_section_c = vim.call('airline#section#create', {vim.g.airline_section_c, '%{nvim_treesitter#statusline()}'})
end

vim.api.nvim_create_autocmd('VimEnter', { callback = airlineInit })

require('nvim-treesitter.configs').setup {
  -- One of "all", "maintained" (parsers with maintainers), or a list of languages
  ensure_installed = "all",

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    disable = {
      'yaml'
    },

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
  indent = {
    disable = {
      'yaml'
    }
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
}

require('mason-lspconfig').setup {
  automatic_installation = true,
}

local servers = { 'bashls', 'dockerls', 'jsonls', 'jdtls', 'kotlin_language_server', 'terraformls', 'yamlls', 'vimls' }
local lspconfig = require('lspconfig')
for _, lsp in pairs(servers) do
  lspconfig[lsp].setup {}
end
--require('pkgbuild')

vim.opt.foldenable = false
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = vim.call('nvim_treesitter#foldexpr') -- TODO

vim.api.nvim_set_hl(0, 'ExtraWhitespace', { ctermfg = 167, fg = '#CC6666', ctermbg = 167, bg = '#CC6666', underdashed = true })
vim.api.nvim_create_autocmd('InsertEnter', { command = 'match ExtraWhitespace /\\s\\+\\%#\\@<!$/' })
vim.api.nvim_create_autocmd('InsertLeave', { command = 'match ExtraWhitespace /\\s\\+$/' })
vim.cmd.match('ExtraWhitespace /\\s\\+$/') -- TODO
vim.api.nvim_create_autocmd('BufWrite', { command = ':%s/\\s\\+$//e' })

vim.api.nvim_create_autocmd({'BufNewFile', 'BufRead'}, { pattern = '*.ino', command = 'let g:airline_section_y .= "%{ArduinoStatusLine()}"'})

