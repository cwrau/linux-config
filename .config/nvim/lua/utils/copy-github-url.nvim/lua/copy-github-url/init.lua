-- maintainers: cwrau, DavidLangen

local M = {}

---@param command string
---@return string|nil
local function getCommandResult(command)
  local commandHandle = io.popen(command, "r")
  local result
  if commandHandle then
    commandHandle:flush()
    result = tostring(commandHandle:read("a"))
    commandHandle:close()
    if result == "" or result == nil then
      result = nil
    else
      result = result:gsub("\n", "")
    end
  end
  return result
end

---@param file string
---@return string|nil
local function getRelativeFilePath(file)
  return getCommandResult("git ls-files --full-name " .. file)
end

---@return string|nil
local function getGitRemote()
  local remoteString = getCommandResult("git remote -v")
  if remoteString then
    for remote in remoteString:gmatch("([^\n]+)") do
      local fields = {}
      for field in remote:gmatch("([^%s]+)") do
        table.insert(fields, field)
      end
      return fields[2]
    end
  end
  return nil
end

---@return string|nil
local function getGithubUrl()
  local remote = getGitRemote()
  local url
  if remote then
    if remote:gmatch("^git@github.com:") then
      url = remote:gsub("git@github.com:", "https://github.com/")
    elseif remote:gmatch("^https://github.com/") then
      url = remote
    else
      return nil
    end
    url = url:gsub(".git$", "")
  end
  return url
end

---@return string|nil
local function getGitBranch()
  return getCommandResult("git branch --show")
end

---@return nil
M.openCurrentFileSelection = function()
  local githubUrl = getGithubUrl()
  if githubUrl then
    local currentFileName = vim.api.nvim_buf_get_name(0)
    local relativeFilePath = getRelativeFilePath(currentFileName)
    if relativeFilePath then
      local branch = assert(getGitBranch(), "Should be in git repo")
      local startLine = vim.fn.getpos("v")[2]
      local endLine = vim.fn.getpos(".")[2]
      local fullFileUrl = githubUrl
        .. "/blob/"
        .. branch
        .. "/"
        .. relativeFilePath
        .. "#L"
        .. startLine
        .. "-L"
        .. endLine
      vim.fn.setreg("*", fullFileUrl)
      vim.notify("Copied GitHub url to clipboard")
    else
      vim.notify("File is not in git repository")
    end
  end
end

M.setup = function()
  require("which-key").register({
    c = {
      g = {
        M.openCurrentFileSelection,
        "Copy GitHub URL of current selection or single line",
      },
    },
  }, { prefix = "<leader>" })
end

return M
