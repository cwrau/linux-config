local M = {}

---@param keybindings table<string, string|function>
function M.create_keybindings(keybindings)
  for key, binding in pairs(keybindings) do
    vim.keymap.set('n', key, binding)
  end
end

return M
