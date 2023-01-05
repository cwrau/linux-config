local M = {}

function M.run()
  vim.api.nvim_create_autocmd('VimEnter', {
    callback = function()
      for _, pkg in pairs(require('mason-registry').get_installed_packages()) do
        pkg:check_new_version(function(new_available, version)
          if new_available then
            local notification = {}
            notification = vim.notify(('Updating %s from %s to %s'):format(pkg.name, version.current_version,
              version.latest_version))
            pkg:install():on('closed', function()
              vim.notify(('Updated %s to %s'):format(pkg.name, version.latest_version), nil,
                { replace = notification })
            end)
          end
        end)
      end
    end
  })
end

return M
