local M = {}

---@param file string
---@return string|nil
M.getRelativeFilePath = function(file)
  local path

  local command = io.popen('git ls-files --full-name ' .. file, 'r')
  if command then
    command:flush()
    path = command:read('a')
    command:close()
    if path == nil then
      print('err')
    else
      print('success: "' .. path .. '"<-')
    end
  end

  return path
end

return M
