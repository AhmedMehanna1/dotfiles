local M = {}

local function ensure_dir(path)
  local dir = vim.fn.fnamemodify(path, ":h")
  if dir ~= "" then
    pcall(vim.fn.mkdir, dir, "p")
  end
end

local function to_path(uri_or_path)
  if type(uri_or_path) ~= "string" or uri_or_path == "" then
    return nil
  end
  if uri_or_path:match("^%a[%w+.-]*://") then
    return vim.uri_to_fname(uri_or_path)
  end
  return uri_or_path
end

-- Apply workspace edits with correct offset encoding per client
local function apply_edit_for_client(edit, client)
  if not edit or not client then
    return
  end
  local enc = client.offset_encoding or "utf-16"
  pcall(vim.lsp.util.apply_workspace_edit, edit, enc)
end

-- Renames a file while informing LSP servers (will/did notifications) so that imports/usages update.
-- Returns true on success, false on failure.
function M.rename_file(old_path, new_path, opts)
  opts = opts or {}
  old_path = to_path(old_path)
  new_path = to_path(new_path)
  if not old_path or not new_path or old_path == new_path then
    return false, "invalid paths"
  end

  local old_uri = vim.uri_from_fname(old_path)
  local new_uri = vim.uri_from_fname(new_path)
  local params = { files = { { oldUri = old_uri, newUri = new_uri } } }

  -- Ask servers for edits before renaming
  local lsp_utils = require("utils.lsp")
  local clients = lsp_utils.get_clients({ method = "workspace/willRenameFiles" })
  for _, client in ipairs(clients) do
    local res = client.request_sync("workspace/willRenameFiles", params, opts.timeout or 10000)
    if res and res.result then
      apply_edit_for_client(res.result, client)
    end
  end

  -- Ensure target directory exists and perform filesystem rename
  ensure_dir(new_path)
  local ok, err = vim.loop.fs_rename(old_path, new_path)
  if not ok then
    ok, err = pcall(os.rename, old_path, new_path)
  end
  if not ok then
    return false, tostring(err)
  end

  -- Notify servers that the rename happened
  for _, client in ipairs(vim.lsp.get_clients()) do
    pcall(function()
      client.notify("workspace/didRenameFiles", params)
    end)
  end

  -- Update any open buffer visiting the old path
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local name = vim.api.nvim_buf_get_name(buf)
      if name == old_path then
        vim.api.nvim_buf_set_name(buf, new_path)
        if not vim.bo[buf].modified then
          pcall(vim.api.nvim_buf_call, buf, function()
            vim.cmd("silent noautocmd edit")
          end)
        end
      end
    end
  end

  return true
end

return M

