local util = require('lspconfig').util

local M = {}

M._get_client = function()
  M.bufnr = vim.api.nvim_get_current_buf()
  M.uri = vim.uri_from_bufnr(M.bufnr)
  if vim.bo.filetype ~= 'yaml' then return end
  if not M.client then
    M.client = util.get_active_client_by_name(M.bufnr, 'yamlls')
  end
  return M.client
end

---@param schema string
M._change_settings = function(schema)
  local client = M._get_client()
  if client == nil then
    return
  end
  local previous_settings = client.config.settings
  if previous_settings.yaml and previous_settings.yaml.schemas then
    for key, value in pairs(previous_settings.yaml.schemas) do
      if vim.tbl_islist(value) then
        for idx, value_value in pairs(value) do
          if value_value == M.uri or string.find(value_value, '*') then
            table.remove(previous_settings.yaml.schemas[key], idx)
          end
        end
      elseif value == M.uri or string.find(value, '*') then
        previous_settings.yaml.schemas[key] = nil
      end
    end
  end
  local new_settings = vim.tbl_deep_extend('force', previous_settings, {
    yaml = {
      schemas = {
        [schema] = M.uri
      }
    }
  })
  client.config.settings = new_settings
  client.notify('workspace/didChangeConfiguration')
end

---@param path string
---@return boolean
local function file_exists(path)
  local file = io.open(path, "r")
  if file == nil then
    return false
  else
    io.close(file)
    return true
  end
end

M.setup = function()
  local fileName = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
  if fileName:find('values.yaml$') then
    local schemaPath
    if fileName:find('/ci/') then
      schemaPath = fileName:gsub('/ci/[^/]-.yaml', '/values.schema.json')
    else
      schemaPath = fileName:gsub('/[^/]-.yaml', '/values.schema.json')
    end

    if file_exists(schemaPath) then
      M._change_settings('file://' .. schemaPath)
      return
    end
  end

  local yaml = table.concat(vim.api.nvim_buf_get_lines(vim.api.nvim_get_current_buf(), 0, -1, false), '\n')
  for apiGroup in yaml:gmatch('\n?apiVersion: (.-)/.-\n') do
    for apiVersion in yaml:gmatch('\n?apiVersion: ' .. apiGroup:gsub('([^%w])', '%%%1') .. '/(.-)\n') do
      for kind in yaml:gmatch('\nkind: (.-)\n') do
        local schemaFile = os.tmpname()
        vim.api.nvim_create_autocmd('VimLeavePre', {
          callback = function() os.remove(schemaFile) end
        })
        local exitCode = os.execute([[timeout 3 kubectl get crd -A -o json | jq -e '.items[] | select(.spec.names.singular == "]]
          .. kind:lower()
          .. [[" and .spec.group == "]]
          .. apiGroup:lower()
          .. [[") | .spec.versions[] | select(.name == "]]
          .. apiVersion .. [[") | .schema.openAPIV3Schema' > ]] .. schemaFile)
        if exitCode == 0 then
          M._change_settings('file://' .. schemaFile)
        else
          M._change_settings('https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/master-standalone-strict/' .. kind:lower() .. '.json')
        end
        return
      end
    end
  end
end

return M
