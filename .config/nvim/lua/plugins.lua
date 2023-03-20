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

  use {
    'windwp/nvim-autopairs',
    config = function()
      require('nvim-autopairs').setup {}
    end
  }

  use {
    'kristijanhusak/vim-hybrid-material', -- Dark Theme
    --'doki-theme/doki-theme-vim', -- Dark Theme
    config = function()
      vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1
      vim.opt.termguicolors = true
      vim.opt.background = 'dark'
      vim.g.enable_bold_font = 1
      vim.g.enable_italic_font = 1
      vim.g.hybrid_transparent_background = 1
      vim.cmd.colorscheme('hybrid_material')
      --vim.cmd.colorscheme('rem')
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
    config = function()
      require('mason').setup()
      require('mason-auto-update').run()
    end
  }

  use {
    'mfussenegger/nvim-dap',
    config = function()
      local dap = require('dap')
      vim.keymap.set('n', '<F21>', function()
        local session = dap.session()
        if session then
          if session.capabilities.supportsRestartRequest then
            dap.restart()
          else
            dap.close()
            dap.run_last()
          end
        else
          dap.run_last()
        end
      end
      )
      require('util').create_keybindings {
        ['<F9>'] = dap.continue,
        ['<F26>'] = dap.disconnect,
        ['<F7>'] = dap.step_into,
        ['<F8>'] = dap.step_over,
        ['<F20>'] = dap.step_out,
        ['<F32>'] = dap.toggle_breakpoint,
      }
    end
  }

  use {
    'theHamsta/nvim-dap-virtual-text',
    after = 'nvim-dap',
    config = function()
      require('nvim-dap-virtual-text').setup {}
    end
  }

  use {
    'rcarriga/nvim-dap-ui',
    requires = 'rcarriga/cmp-dap',
    after = { 'nvim-dap', 'nvim-cmp', 'nvim-autopairs' },
    config = function()
      local dap = require('dap')
      local dapui = require('dapui')
      local cmp = require('cmp')

      cmp.setup {
        enabled = function()
          local default = require('cmp.config.default')().enabled()
          local custom = require('cmp_dap').is_dap_buffer()
          return default or custom
        end
      }
      cmp.setup.filetype(
        { 'dap-repl', 'dapui_watches', 'dapui_hover' },
        {
          sources = {
            { name = 'dap' }
          }
        }
      )

      dapui.setup {
        layouts = {
          {
            elements = {
              { id = "scopes",      size = 0.25, },
              { id = "breakpoints", size = 0.25 },
              { id = "stacks",      size = 0.25 },
              { id = "watches",     size = 0.25 },
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              "repl",
            },
            size = 10,
            position = "bottom",
          },
        },
      }

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.after.event_exited['dapui_config'] = function(_, err)
        if err.exitCode == 0 then
          dapui.close {}
        end
      end

      vim.keymap.set('n', '<M-$>', dapui.toggle)

      vim.api.nvim_set_hl(0, 'DapBreakpoint', { ctermbg = 0, fg = '#993939', bg = '#31353f' })
      vim.api.nvim_set_hl(0, 'DapLogPoint', { ctermbg = 0, fg = '#61afef', bg = '#31353f' })
      vim.api.nvim_set_hl(0, 'DapStopped', { ctermbg = 0, fg = '#98c379', bg = '#31353f' })
      vim.api.nvim_set_hl(0, 'DapStoppedLine', { ctermbg = 0, bg = '#31353f' })

      vim.fn.sign_define('DapBreakpoint', { text = '', texthl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
      vim.fn.sign_define('DapBreakpointCondition', { text = 'ﳁ', texthl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
      vim.fn.sign_define('DapBreakpointRejected', { text = '', texthl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
      vim.fn.sign_define('DapLogPoint', { text = '', texthl = 'DapLogPoint', numhl = 'DapLogPoint' })
      vim.fn.sign_define('DapStopped',
        { text = '', texthl = 'DapStopped', linehl = 'DapStoppedLine', numhl = 'DapStopped' })

      vim.api.nvim_create_autocmd('VimResized', {
        callback = function()
          local windows = require('dapui.windows')
          for _, win_layout in ipairs(windows.layouts) do
            if win_layout:is_open() then
              dapui.open {
                reset = true
              }
              break
            end
          end
        end
      })
    end
  }

  use {
    'williamboman/mason-lspconfig.nvim',
    after = { 'mason.nvim', 'nvim-lspconfig' },
    config = function()
      local mason_lspconfig = require('mason-lspconfig')
      mason_lspconfig.setup {
        --automatic_installation = true,
        ensure_installed = {
          'bashls',
          'clangd',
          'dockerls',
          'gopls',
          'jdtls',
          'jsonls',
          'kotlin_language_server',
          'lua_ls',
          'pyright',
          'terraformls',
          'vimls',
          'yamlls',
        }
      }
      mason_lspconfig.setup_handlers {
        function(server_name)
          local lspconfig = require('lspconfig')
          local custom_setup = {
            ['lua_ls'] = {
              settings = {
                Lua = {
                  diagnostics = {
                    globals = {
                      'vim'
                    }
                  },
                  hint = {
                    enable = true
                  },
                  workspace = {
                    checkThirdParty = false
                  }
                }
              }
            },
            ['gopls'] = {
              settings = {
                gopls = {
                  hints = {
                    parameterNames = true
                  }
                }
              }
            },
            ['yamlls'] = {
              on_attach = function()
                if vim.bo.filetype == "helm" then
                  vim.cmd("LspStop yamlls")
                end
              end
            }
          }

          if custom_setup[server_name] ~= nil then
            lspconfig[server_name].setup(custom_setup[server_name])
          else
            lspconfig[server_name].setup {
              on_attach = function()
                vim.notify(server_name)
              end
            }
          end
        end,
        ['yamlls'] = function()
          require('lspconfig').yamlls.setup {
            on_attach = function(_, _)
              print("yamlls")
            end
          }
        end
      }
    end
  }

  use {
    'hrsh7th/nvim-cmp',
    requires = { 'L3MON4D3/LuaSnip', 'onsails/lspkind.nvim', 'hrsh7th/cmp-nvim-lsp', 'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path', 'hrsh7th/cmp-cmdline' },
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
            mode = 'symbol',
            maxwidth = 25
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

      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources(
          { { name = 'buffer' } }
        )
      })
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources(
          { { name = 'path' } },
          { { name = 'cmdline' } }
        )
      })

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
        ensure_installed = { 'python', 'delve', 'bash', 'kotlin' },
      }
      mason_dap.setup_handlers()
    end
  }

  use {
    'neovim/nvim-lspconfig',
    requires = { 'folke/neodev.nvim', 'nvim-lua/plenary.nvim' },
    after = 'nvim-cmp',
    config = function()
      require('neodev').setup {}

      local lsp_defaults = require('lspconfig').util.default_config
      lsp_defaults.capabilities = vim.tbl_deep_extend(
        'force',
        lsp_defaults.capabilities,
        require('cmp_nvim_lsp').default_capabilities()
      )

      vim.api.nvim_create_autocmd('VimEnter',
        {
          pattern = '*.yaml',
          callback = function(_)
            require('yaml-schema-select').setup()
          end
        }
      )

      vim.keymap.set('n', '=', vim.lsp.buf.format)
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
    'ThePrimeagen/refactoring.nvim',
    after = 'telescope.nvim'
  }

  use {
    'jose-elias-alvarez/null-ls.nvim',
    requires = 'nvim-lua/plenary.nvim',
    after = { 'mason.nvim', 'refactoring.nvim' },
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
        null_ls.builtins.diagnostics.yamllint.with {
          disabled_filetypes = { 'helm' }
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
          'zsh',
        },
        formatting = {
          'black',
          'isort',
          'prettier',
        },
        code_actions = {
          'refactoring',
          'shellcheck',
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

      local refactorings = require('refactoring')

      require('util').create_keybindings {
        ['<C-M-n>'] = function() refactorings.refactor('Inline Variable') end,
        ['<C-M-m>'] = function() refactorings.refactor('Extract Function') end,
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

  use {
    'nvim-telescope/telescope.nvim',
    requires = 'nvim-lua/plenary.nvim',
    config = function()
      vim.keymap.set('n', '<C-N>', function()
        require('telescope.builtin').find_files {
          hidden = true,
        }
      end)
      vim.keymap.set('n', '<C-F>', function()
        require('telescope.builtin').live_grep {
          additional_args = {
            '--hidden',
            '--glob=!.git',
          }
        }
      end)
    end
  }

  use {
    'rcarriga/nvim-notify',
    after = 'telescope.nvim',
    config = function()
      local notify = require('notify')
      notify.setup {
        background_colour = "#000000",
        stages = 'fade'
      }
      vim.notify = notify
      require("telescope").load_extension("notify")
    end
  }

  use 'RRethy/vim-illuminate'

  use {
    'ray-x/navigator.lua',
    requires = { 'ray-x/guihua.lua' },
    after = { 'nvim-lspconfig', 'nvim-treesitter' },
    config = function()
      local keymap = {}
      local keybindings = {
        ['n'] = {
          ['<C-b>'] = { func = require('navigator.reference').async_ref, desc = 'IDEA definition' },
          ['<C-q>'] = { func = vim.lsp.buf.hover, desc = "IDEA hover" },
          ['<M-CR>'] = { func = require('navigator.codeAction').code_action, desc = 'IDEA action' },
          ['<F18>'] = { func = require('navigator.rename').rename, desc = 'IDEA rename' },
        }
      }

      for mode, layer in pairs(keybindings) do
        for key, binding in pairs(layer) do
          table.insert(keymap, {
            key = key,
            mode = mode,
            func = binding.func,
            desc = binding.desc or '',
          })
        end
      end

      require('navigator').setup {
        mason = true,
        keymaps = keymap
      }
    end
  }

  require('open-github-url').setup()
end)
