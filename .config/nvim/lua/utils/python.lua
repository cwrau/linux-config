local path = require("lspconfig.util").path

local M = {}

function M.get_python_path(workspace)
  if vim.env.VIRTUAL_ENV then
    return path.join(vim.env.VIRTUAL_ENV, "bin", "python")
  end

  for _, pattern in ipairs({ "*", ".*" }) do
    local match = vim.fn.glob(path.join(workspace, pattern, "venv"))
    if match ~= "" then
      return path.join(match, "bin", "python")
    end
  end

  return "python"
end

return M
