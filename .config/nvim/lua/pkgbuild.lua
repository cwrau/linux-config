local lspconfig = require('lspconfig')
local pkgbuildls = lspconfig.bashls
pkgbuildls.document_config.default_config.cmd_env.SHELLCKECK_PATH = '/usr/local/bin/pkgbuild_shellcheck'
lspconfig.configs.pkgbuildls = pkgbuildls.document_config.default_config
print(vim.inspect(pkgbuildls))
