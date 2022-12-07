return require('packer').startup(function(use)
  vim.api.nvim_create_autocmd('BufWritePost', {
    pattern = "plugins.lua",
    callback = function()
      require('plugins')
      vim.cmd('source <afile> | PackerCompile')
    end
  })

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
      vim.g.hybrid_transparent_background = 1
      vim.cmd.colorscheme('hybrid_material')
    end
  }

  use 'tpope/vim-surround' -- Easy add matching parentheses

  use {
    'nvim-treesitter/nvim-treesitter',
    --requires = 'nvim-treesitter/playground',
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
        }
      }

      vim.opt.foldenable = false
      vim.opt.foldmethod = 'expr'
      vim.opt.foldexpr = vim.call('nvim_treesitter#foldexpr') -- TODO
    end
  }

  use {
    'lukas-reineke/indent-blankline.nvim',
    after = 'nvim-treesitter',
    config = function()
      require('indent_blankline').setup {
        show_current_context = true,
        show_current_context_start = true,
      }
    end
  }

  use {
    'folke/trouble.nvim',
    requires = 'kyazdani42/nvim-web-devicons',
    after = 'nvim-lspconfig',
    config = function()
      require('trouble').setup()

      vim.keymap.set('n', '<C-t>', '<cmd>TroubleToggle<cr>')
    end
  }

  use {
    'towolf/vim-helm',
    ft = 'helm'
  }

  use {
    'farmergreg/vim-lastplace',
    config = function()
      require('lightspeed').setup {
        ignore_case = true
      }
    end
  }

  use 'ggandor/lightspeed.nvim'

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
    config = function() require('mason').setup() end
  }

  use {
    'mfussenegger/nvim-dap',
    config = function()
      local dap = require('dap')
      vim.keymap.set('n', '<F21>', function()
        if dap.session() then
          dap.restart()
        else
          dap.continue()
        end
      end
      )
      vim.keymap.set('n', '<F9>', dap.continue)
      vim.keymap.set('n', '<F26>', dap.disconnect)
      vim.keymap.set('n', '<F7>', dap.step_into)
      vim.keymap.set('n', '<F8>', dap.step_over)
      vim.keymap.set('n', '<F20>', dap.step_out)
      vim.keymap.set('n', '<F32>', dap.toggle_breakpoint)
    end
  }

  use {
    'theHamsta/nvim-dap-virtual-text',
    after = 'nvim-dap',
    config = function()
      require('nvim-dap-virtual-text').setup()
    end
  }

  use {
    'rcarriga/nvim-dap-ui',
    after = 'nvim-dap',
    config = function()
      local dap = require('dap')
      local dapui = require('dapui')

      dapui.setup()

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.after.event_terminated['dapui_config'] = dapui.close
      dap.listeners.after.event_exited['dapui_config'] = dapui.close
      vim.api.nvim_create_autocmd('VimResized', {
        callback = function()
          local windows = require('dapui.windows')
          local is_open = false
          for _, win_layout in ipairs(windows.layouts) do
            if win_layout:is_open() then
              is_open = true
              break
            end
          end

          if is_open then
            dapui.open {
              reset = true
            }
          end
        end
      })
    end
  }

  use {
    'williamboman/mason-lspconfig.nvim',
    after = 'mason.nvim',
    config = function()
      require('mason-lspconfig').setup {
        automatic_installation = true
      }
    end
  }

  use {
    'hrsh7th/nvim-cmp',
    requires = { 'L3MON4D3/LuaSnip', 'onsails/lspkind.nvim', 'hrsh7th/cmp-nvim-lsp', 'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path' },
    config = function()
      local cmp = require('cmp')
      local lspkind = require('lspkind')
      cmp.setup {
        snippet = {
          expand = function(args) require('luasnip').lsp_expand(args.body) end
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete {},
          ['<CR>'] = function(fallback)
            if cmp.visible() then
              if cmp.get_selected_entry() then
                cmp.confirm { behavior = cmp.ConfirmBehavior.Replace, select = true }
                return
              end
            end
            fallback()
          end,
          ['<Tab>'] = cmp.mapping(function(fallback)
            local entries = cmp.get_entries()
            if #entries > 0 and (#entries == 1 or entries[1].exact) then
              cmp.confirm { select = true }
            elseif cmp.visible() then
              cmp.select_next_item { behavior = cmp.SelectBehavior.Select }
            else
              fallback()
            end
          end, { 'i', 's' }
          ),
          ['<S-Tab>'] = function(fallback)
            if cmp.visible() then
              cmp.select_prev_item { behavior = cmp.SelectBehavior.Select }
            else
              fallback()
            end
          end
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        }),
        formatting = {
          format = lspkind.cmp_format {
            mode = 'symbol'
          }
        },
        confirm_opts = {
          behavior = cmp.ConfirmBehavior.Replace,
          select = false,
        },
        window = {
          documentation = {
            winhighlight = 'Normal:CmpPmenu,FloatBorder:CmpPmenuBorder,Search:None',
          },
          completion = {
            winhighlight = 'Normal:CmpPmenu,CursorLine:PmenuSel,Search:None',
          },
        },
        view = {
          entries = {
            name = 'custom',
          }
        },
        experimental = {
          ghost_text = true
        },
      }

      vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
    end
  }

  use {
    'mfussenegger/nvim-dap-python',
    after = { 'mason-nvim-dap.nvim', 'mason.nvim' },
    ft = 'python',
    config = function()
      local registry = require('mason-registry')
      local debugpy_package = registry.get_package('debugpy')
      if not debugpy_package:is_installed() then
        vim.notify("debugpy is not installed 😕", vim.log.levels.ERROR)
      else
        local path = require('mason-core.path')
        require('dap-python').setup(path.concat { debugpy_package:get_install_path(), 'venv', 'bin', 'python3' })
      end
    end
  }

  use {
    'jayp0521/mason-nvim-dap.nvim',
    after = { 'nvim-dap', 'mason.nvim' },
    config = function()
      local mason_dap = require('mason-nvim-dap')
      mason_dap.setup {
        automatic_installation = true,
        automatic_setup = true,
        ensure_installed = { 'python', 'delve', 'bash' },
      }
      mason_dap.setup_handlers()
    end
  }

  use {
    'neovim/nvim-lspconfig',
    requires = 'folke/neodev.nvim',
    after = 'nvim-cmp',
    config = function()
      require('neodev').setup {}

      local lspconfig = require('lspconfig')
      local lsp_defaults = lspconfig.util.default_config
      lsp_defaults.capabilities = vim.tbl_deep_extend(
        'force',
        lsp_defaults.capabilities,
        require('cmp_nvim_lsp').default_capabilities()
      )

      local servers = {
        'bashls',
        'dockerls',
        'jdtls',
        'jsonls',
        'kotlin_language_server',
        'pyright',
        'terraformls',
        'vimls',
      }
      for _, server in pairs(servers) do
        lspconfig[server].setup {}
      end

      lspconfig['sumneko_lua'].setup {
        settings = {
          Lua = {
            hint = {
              enable = true
            },
            workspace = {
              checkThirdParty = false
            }
          }
        }
      }
      lspconfig['gopls'].setup {
        settings = {
          gopls = {
            hints = {
              parameterNames = true
            }
          }
        }
      }
      lspconfig['yamlls'].setup {
        --        settings = {
        --          yaml = {
        --            validate = true,
        --            schemaStore = {
        --              enable = true,
        --              url = 'https://www.schemastore.org/api/json/catalog.json'
        --            },
        --            schemaDownload = {
        --              enable = true
        --            },
        --            schemas = {
        --              ['https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/master-standalone-strict/all.json'] = '/*kubectl-edit-*.yaml'
        --            }
        --          }
        --        },
        on_attach = function()
          require('yaml-schema-select').setup()
        end
      }
      --require('pkgbuild')

      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function()
          local keybindings = {
            ['<C-b>'] = vim.lsp.buf.definition,
            ['<C-q>'] = vim.lsp.buf.hover,
            ['<F18>'] = vim.lsp.buf.rename,
            ['<F55>'] = vim.lsp.buf.incoming_calls,
            ['<M-CR>'] = vim.lsp.buf.code_action,
            ['='] = vim.lsp.buf.format,
          }
          for key, binding in pairs(keybindings) do
            vim.keymap.set('n', key, binding)
          end
        end
      })
    end
  }

  use {
    'ray-x/lsp_signature.nvim',
    after = 'nvim-lspconfig',
    config = function()
      require('lsp_signature').setup {
        close_timeout = 500,
        always_trigger = true
      }
    end
  }

  use {
    'lvimuser/lsp-inlayhints.nvim',
    after = 'nvim-lspconfig',
    config = function()
      local lh = require('lsp-inlayhints')
      lh.setup()
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          lh.on_attach(vim.lsp.get_client_by_id(args.data.client_id), args.buf, false)
        end
      })
    end
  }

  use {
    'jose-elias-alvarez/null-ls.nvim',
    requires = 'nvim-lua/plenary.nvim',
    after = 'mason.nvim',
    config = function()
      local null_ls = require('null-ls')
      local sources = {
        null_ls.builtins.formatting.shfmt.with {
          extra_args = { '-i', '2', '-ci' }
        },
        null_ls.builtins.formatting.beautysh.with {
          extra_args = { '-i', '2', '--force-function-style', 'fnpar' },
          disabled_filetypes = { 'sh', 'bash' }
        },
      }
      local tools = {
        diagnostics = {
          'actionlint',
          'flake8',
          'jsonlint',
          'luacheck',
          'markdownlint',
          'revive',
          'shellcheck',
          'todo_comments',
          'yamllint',
          'zsh',
        },
        formatting = {
          'black',
          'isort',
          'prettier',
        }
      }

      for type, type_sources in pairs(tools) do
        for _, source in pairs(type_sources) do
          table.insert(sources, null_ls.builtins[type][source])
        end
      end

      null_ls.setup {
        sources = sources
      }
    end
  }

  use {
    'jay-babu/mason-null-ls.nvim',
    after = { 'mason.nvim', 'null-ls.nvim' },
    config = function()
      local mason_null_ls = require('mason-null-ls')
      mason_null_ls.setup {
        ensure_installed = nil,
        automatic_installation = true,
        automatic_setup = true,
      }
    end
  }

  use {
    'terrortylor/nvim-comment',
    config = function()
      require('nvim_comment').setup {
        line_mapping = '<C-_>'
      }
    end
  }

  use {
    'plasticboy/vim-markdown',
    ft = 'markdown'
  }

  use {
    'iamcco/markdown-preview.nvim',
    run = function() vim.fn['mkdp#util#install']() end,
    config = function() vim.g.mkdp_browser = 'xdg-open' end,
    ft = 'markdown'
  }

  require('open-github-url').setup()
end)
