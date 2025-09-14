local M = {}

local function input(prompt, default)
  local ok, new = pcall(vim.fn.input, { prompt = prompt .. ": ", default = default or "", cancelreturn = "" })
  if not ok or new == "" then
    return nil
  end
  return new
end

-- Best-effort OmniSharp rename when on C#
local function try_omnisharp_rename(new_name)
  if vim.bo.filetype == "cs" and vim.fn.exists(":OmniSharpRename") == 2 then
    if new_name and new_name ~= "" then
      vim.cmd("OmniSharpRename " .. new_name)
    else
      vim.cmd("OmniSharpRename")
    end
    return true
  end
  return false
end

-- Wrapper around builtin LSP rename to ensure cross-usage rename
function M.smart()
  local buf = vim.api.nvim_get_current_buf()
  local old_word = vim.fn.expand('<cword>')
  local path = vim.api.nvim_buf_get_name(buf)
  local base = path ~= "" and vim.fn.fnamemodify(path, ":t:r") or nil

  -- If the symbol matches the filename stem, treat as class/type rename and rename file too
  if base and old_word ~= "" and base == old_word then
    return M.rename_class_and_file()
  end

  -- Otherwise do a regular rename across usages
  if try_omnisharp_rename() then
    return
  end
  vim.lsp.buf.rename()
end

-- Rename class/type and optionally rename file to match
function M.rename_class_and_file()
  local buf = vim.api.nvim_get_current_buf()
  local old_word = vim.fn.expand('<cword>')
  if not old_word or old_word == "" then
    vim.notify("No symbol under cursor", vim.log.levels.WARN)
    return
  end

  local new_name = input("New class name", old_word)
  if not new_name or new_name == old_word then
    return
  end

  -- First, rename the symbol via language-specific or LSP
  if not try_omnisharp_rename(new_name) then
    local ok_direct = pcall(function()
      vim.lsp.buf.rename(new_name)
    end)
    if not ok_direct then
      -- If direct failed (older nvim), prompt-based fallback
      vim.lsp.buf.rename()
    end
  end

  -- Then, if filename matches old class name, rename the file as well
  local old_path = vim.api.nvim_buf_get_name(buf)
  if old_path == "" then
    return
  end
  local dir = vim.fn.fnamemodify(old_path, ":h")
  local base = vim.fn.fnamemodify(old_path, ":t:r")
  local ext = vim.fn.fnamemodify(old_path, ":e")

  -- Only rename file when basename equals old class name
  if base ~= old_word then
    return
  end

  local new_path = dir .. "/" .. new_name .. (ext ~= "" and ("." .. ext) or "")
  if new_path == old_path then
    return
  end

  if vim.loop.fs_stat(new_path) then
    vim.notify("Target file exists: " .. new_path, vim.log.levels.ERROR)
    return
  end

  -- Special handling for TypeScript to update imports if possible
  local function try_ts_rename_file()
    local ok_ts, ts = pcall(require, "typescript")
    if not ok_ts then
      return false
    end
    -- Try different APIs exposed by typescript.nvim
    local ok_call = false
    -- actions.renameFile(old, new)
    if ts.actions and type(ts.actions.renameFile) == "function" then
      local ok, _ = pcall(ts.actions.renameFile, old_path, new_path)
      ok_call = ok or ok_call
    end
    -- renameFile({ source = old, target = new })
    if not ok_call and type(ts.renameFile) == "function" then
      local ok, _ = pcall(ts.renameFile, { source = old_path, target = new_path })
      ok_call = ok or ok_call
    end
    -- rename_file(old, new)
    if not ok_call and type(ts.rename_file) == "function" then
      local ok, _ = pcall(ts.rename_file, old_path, new_path)
      ok_call = ok or ok_call
    end
    return ok_call
  end

  local did_special = false
  if vim.bo.filetype == "typescript" or vim.bo.filetype == "typescriptreact" or vim.bo.filetype == "javascript" or vim.bo.filetype == "javascriptreact" then
    did_special = try_ts_rename_file()
  end

  if not did_special then
    local ok, err = require("utils.fileops").rename_file(old_path, new_path)
    if not ok then
      vim.notify("File rename failed: " .. tostring(err), vim.log.levels.ERROR)
      return
    end
  else
    -- If typescript.nvim handled it, make sure current window visits new path
    vim.cmd("edit " .. vim.fn.fnameescape(new_path))
  end

  -- Java helpers: organize imports after rename
  if vim.bo.filetype == "java" then
    pcall(function()
      require("jdtls").organize_imports()
    end)
  end

  vim.notify("Renamed class and file to " .. new_name, vim.log.levels.INFO)
end

-- Expose commands for convenience
vim.api.nvim_create_user_command("SmartRename", function()
  M.smart()
end, { desc = "Smart rename symbol across usages" })

vim.api.nvim_create_user_command("RenameClassFile", function()
  M.rename_class_and_file()
end, { desc = "Rename class/type and file if needed" })

return M
