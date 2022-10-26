return require('packer').startup(function(use)
  vim.api.nvim_create_autocmd('BufWritePost', {
    pattern = "plugins.lua",
    callback = function()
      require('plugins')
      vim.cmd('PackerSync')
      vim.cmd('source <afile> | PackerCompile')
    end
  })

  use {
    'Shougo/deoplete.nvim',
    run = ':UpdateRemotePlugins',
    config = function()
      vim.g['deoplete#enable_at_startup'] = true
      vim.g.python3_host_prog = '/usr/bin/python'
      -- use tab to forward cycle
      --inoremap <silent><expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
      -- use tab to backward cycle
      --inoremap <silent><expr><s-tab> pumvisible() ? "\<c-p>" : "\<s-tab>"
      -- Close the documentation window when completion is done
      vim.api.nvim_create_autocmd({ 'InsertLeave', 'CompleteDone' },
        { command = 'if pumvisible() == 0 | silent! pclose! | endif' })
    end
  }

  use 'vim-airline/vim-airline' -- better monitoring

  use 'mhinz/vim-signify'

  use 'jiangmiao/auto-pairs' -- add eg. (->)

  use {
    'kristijanhusak/vim-hybrid-material', -- Dark Theme
    config = function()
      vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1
      vim.opt.termguicolors = true
      vim.opt.background = 'dark'
      vim.g.enable_bold_font = 1
      vim.g.enable_italic_font = 1
      vim.cmd.colorscheme('hybrid_material')
    end
  }

  use 'tpope/vim-surround' -- Easy add matching parentheses

  use {
    'lukas-reineke/indent-blankline.nvim',
    requires = 'nvim-treesitter/nvim-treesitter',
    config = function()
      require('indent_blankline').setup {
        show_current_context = true,
        show_current_context_start = true,
      }
    end
  }

  use {
    'nvim-treesitter/nvim-treesitter',
    run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
    config = function()
      require('nvim-treesitter.configs').setup {
        -- One of 'all', 'maintained' (parsers with maintainers), or a list of languages
        ensure_installed = 'all',
        sync_install = false,

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
            init_selection = 'gnn',
            node_incremental = 'grn',
            scope_incremental = 'grc',
            node_decremental = 'grm',
          },
        },
      }

      vim.opt.foldenable = false
      vim.opt.foldmethod = 'expr'
      vim.opt.foldexpr = vim.call('nvim_treesitter#foldexpr') -- TODO
    end
  }

  use {
    'folke/trouble.nvim',
    requires = 'kyazdani42/nvim-web-devicons',
    config = function()
      require('trouble').setup {}

      vim.keymap.set('n', '<c-t>', '<cmd>TroubleToggle<cr>')
    end
  }

  use {
    'towolf/vim-helm',
    ft = 'helm'
  }

  use 'farmergreg/vim-lastplace'

  use 'pgdouyon/vim-evanesco'

  use 'mhinz/vim-startify'

  use {
    'mechatroner/rainbow_csv',
    ft = 'csv'
  }

  use {
    'stevearc/vim-arduino',
    ft = 'arduino',
    config = function()
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
        vim.g.airline_section_c = vim.call('airline#section#create',
          { vim.g.airline_section_c, '%{nvim_treesitter#statusline()}' })
      end
      vim.api.nvim_create_autocmd('VimEnter', { callback = airlineInit })
      vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' },
        { pattern = '*.ino', command = 'let g:airline_section_y .= "%{ArduinoStatusLine()}"' })
    end
  }

  use 'sedm0784/vim-you-autocorrect'

  use {
    'williamboman/mason.nvim',
    config = function() require('mason').setup {} end
  }

  use {
    'williamboman/mason-lspconfig.nvim',
    requires = 'williamboman/mason.nvim',
    config = function()
      require('mason-lspconfig').setup {
        automatic_installation = true
      }
    end
  }

  use {
    'neovim/nvim-lspconfig',
    config = function()
      local nvimLuaConfigLspConfig = function(_, config)
        local file_name = vim.api.nvim_buf_get_name(0)
        if not file_name:find('/home/[^/]+/.config/nvim/%S+%.lua') then
          return
        end
        config.settings.Lua.diagnostics = {
          globals = { 'vim' }
        }
      end

      local servers = { 'bashls', 'dockerls', 'jsonls', 'jdtls', 'kotlin_language_server', 'terraformls', 'yamlls',
        'vimls' }
      local lspconfig = require('lspconfig')
      for _, lsp in pairs(servers) do
        lspconfig[lsp].setup {}
      end
      lspconfig['sumneko_lua'].setup {
        before_init = nvimLuaConfigLspConfig
      }
      --require('pkgbuild')

      vim.keymap.set('n', '=', vim.lsp.buf.format)
    end
  }

  use {
    'plasticboy/vim-markdown',
    ft = 'markdown'
  }

  use {
    'iamcco/markdown-preview.nvim',
    run = function() vim.fn['mkdp#util#install']() end,
    config = function() vim.g.mkdp_browser = 'xdg-open' end
  }
end)
