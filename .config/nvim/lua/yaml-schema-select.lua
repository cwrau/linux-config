local util = require('lspconfig').util

local M = {}

---@return table|nil
local function get_client()
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo.filetype ~= 'yaml' then
    return nil
  end
  return util.get_active_client_by_name(bufnr, 'yamlls')
end

---@param schema string
local function change_settings(schema)
  local client = get_client()
  if client == nil then
    return
  end
  local bufnr = vim.api.nvim_get_current_buf()
  local uri = vim.uri_from_bufnr(bufnr)
  local previous_settings = client.config.settings
  if previous_settings.yaml and previous_settings.yaml.schemas then
    for key, value in pairs(previous_settings.yaml.schemas) do
      if vim.tbl_islist(value) then
        for idx, value_value in pairs(value) do
          if value_value == uri or string.find(value_value, '*') then
            table.remove(previous_settings.yaml.schemas[key], idx)
          end
        end
      elseif value == uri or string.find(value, '*') then
        previous_settings.yaml.schemas[key] = nil
      end
    end
  end
  local new_settings = vim.tbl_deep_extend('force', previous_settings, {
    yaml = {
      schemas = {
        [schema] = uri
      }
    }
  })
  client.config.settings = new_settings
  client.notify('workspace/didChangeConfiguration')
end

---@param path string
---@return boolean
local function file_exists(path)
  local file = io.open(path, 'r')
  if file == nil then
    return false
  else
    io.close(file)
    return true
  end
end

function M.setup()
  local fileName = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
  if fileName:find('values.yaml$') then
    local schemaPath
    if fileName:find('/ci/') then
      schemaPath = fileName:gsub('/ci/[^/]-.yaml', '/values.schema.json')
    else
      schemaPath = fileName:gsub('/[^/]-.yaml', '/values.schema.json')
    end

    if file_exists(schemaPath) then
      change_settings('file://' .. schemaPath)
      return
    end
  end

  local yaml = table.concat(vim.api.nvim_buf_get_lines(vim.api.nvim_get_current_buf(), 0, -1, false), '\n')
  for apiGroup in yaml:gmatch('\n?apiVersion: (.-)/.-\n') do
    for apiVersion in yaml:gmatch('\n?apiVersion: ' .. apiGroup:gsub('([^%w])', '%%%1') .. '/(.-)\n') do
      for kind in yaml:gmatch('\nkind: (.-)\n') do
        local schemaFile = os.tmpname()
        vim.api.nvim_create_autocmd('VimLeavePre', {
          desc = 'yaml: auto-k8s-schema-detect: cleanup temporary file',
          callback = function() os.remove(schemaFile) end
        })
        require('plenary.job'):new({
          command = 'bash',
          args = {
            '-c', [[timeout 3 kubectl get crd -A -o json | jq -e '.items[] | select(.spec.names.singular == "]]
                .. kind:lower()
                .. [[" and .spec.group == "]]
                .. apiGroup:lower()
                .. [[") | .spec.versions[] | select(.name == "]]
                .. apiVersion .. [[") | .schema.openAPIV3Schema' > ]] .. schemaFile
          },
          enable_recording = true,
          on_exit = function(job, exitCode, _)
            vim.schedule(function()
              if exitCode == 0 then
                vim.notify('Using schema from cluster-CRD')
                change_settings('file://' .. schemaFile)
              else
                vim.notify('Using schema from github. Cluster-CRD failed with ' .. vim.inspect(job:stderr_result()))
                change_settings('https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/master-standalone-strict/'
                  .. kind:lower() .. '.json')
              end
            end)
          end
        }):start()
        return
      end
    end
  end
end

return M