local M = {}

local function get_current_package(buf)
  buf = buf or 0
  local lines = vim.api.nvim_buf_get_lines(buf, 0, math.min(50, vim.api.nvim_buf_line_count(buf)), false)
  for _, line in ipairs(lines) do
    local pkg = line:match("^%s*package%s+([%w_%.]+)%s*;")
    if pkg then
      return pkg
    end
  end
  return nil
end

local function basename(path)
  return vim.fn.fnamemodify(path, ":t")
end

local function join_paths(a, b)
  if a:sub(-1) == "/" then
    return a .. b
  else
    return a .. "/" .. b
  end
end

-- Try to determine source root by removing the current package path from file path
local function detect_source_root(file_path, current_pkg)
  if not current_pkg then
    return vim.fn.fnamemodify(file_path, ":h") -- fallback
  end
  local pkg_path = current_pkg:gsub("%%", "%%%%"):gsub("%.", "/")
  -- Find the last occurrence of the package path in the file path
  local last_idx
  local start = 1
  while true do
    local s, e = file_path:find("/" .. pkg_path, start, true)
    if not s then break end
    last_idx = s
    start = e + 1
  end
  if last_idx then
    return file_path:sub(1, last_idx - 1)
  end
  -- Fallback: look for src/main/java or src/test/java
  local m = file_path:match("(.-/src/[^\n]+/java)/")
  if m then
    return m
  end
  return vim.fn.fnamemodify(file_path, ":h")
end

-- Move current Java file to a new package and update references via LSP
function M.move_to_package(new_package)
  if vim.bo.filetype ~= "java" then
    vim.notify("Not a Java file", vim.log.levels.WARN)
    return
  end
  local buf = 0
  local file_path = vim.api.nvim_buf_get_name(buf)
  if file_path == "" then return end

  local current_pkg = get_current_package(buf)
  if not new_package or new_package == "" then
    new_package = vim.fn.input({ prompt = "New package: ", default = current_pkg or "", cancelreturn = "" })
  end
  if not new_package or new_package == "" then return end

  local root = detect_source_root(file_path, current_pkg)
  local new_pkg_path = new_package:gsub("%.", "/")
  local new_dir = join_paths(root, new_pkg_path)
  local target = join_paths(new_dir, basename(file_path))

  local ok, err = require("utils.fileops").rename_file(file_path, target)
  if not ok then
    vim.notify("Move to package failed: " .. tostring(err), vim.log.levels.ERROR)
    return
  end

  -- Update package declaration to new package
  if current_pkg ~= new_package then
    local lines = vim.api.nvim_buf_get_lines(buf, 0, math.min(50, vim.api.nvim_buf_line_count(buf)), false)
    for i, line in ipairs(lines) do
      local s = line:match("^%s*package%s+([%w_%.]+)%s*;")
      if s then
        lines[i] = line:gsub("([%w_%.]+)%s*;", new_package .. ";", 1)
        vim.api.nvim_buf_set_lines(buf, 0, math.min(50, vim.api.nvim_buf_line_count(buf)), false, lines)
        break
      end
    end
  end

  -- Organize imports in the moved file; other files should get updated by will/didRename
  pcall(function()
    require("jdtls").organize_imports()
  end)

  vim.notify("Moved to package " .. new_package, vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("JavaMoveToPackage", function(opts)
  M.move_to_package(opts.args ~= "" and opts.args or nil)
end, { nargs = "?", desc = "Move current Java file to a new package" })

return M

