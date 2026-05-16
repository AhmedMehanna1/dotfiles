local M = {}

---@param path string
---@return string|nil
local function read_file(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok or not lines or vim.tbl_isempty(lines) then
    return nil
  end
  local text = table.concat(lines, "\n")
  text = text:gsub("\r", "")
  text = vim.trim(text)
  if text == "" then
    return nil
  end
  return text
end

---@param path string
---@return boolean
local function is_dir(path)
  return vim.fn.isdirectory(path) == 1
end

---@param java_home string
---@return boolean
local function is_java_home(java_home)
  if not java_home or java_home == "" then
    return false
  end
  if not is_dir(java_home) then
    return false
  end
  return vim.fn.executable(java_home .. "/bin/java") == 1
end

---@param root_dir string
---@param rel string
---@return string
local function join(root_dir, rel)
  return (root_dir:gsub("/+$", "")) .. "/" .. rel
end

---@param s string
---@return string|nil
local function major_version(s)
  s = vim.trim(s)
  if s == "" then
    return nil
  end
  local n = s:match("^(%d+)")
  return n
end

---@return table<string, string>
local function home_map()
  local map = vim.g.java_home_map
  if type(map) == "table" then
    return map
  end
  return {}
end

---@param root_dir string
---@return string|nil
function M.detect_java_home(root_dir)
  if type(root_dir) ~= "string" or root_dir == "" then
    return nil
  end

  -- 1) Prefer an explicit per-project override file
  for _, rel in ipairs({ ".nvim/java-home", ".nvim/java_home", ".java-home", ".java_home" }) do
    local value = read_file(join(root_dir, rel))
    if value then
      local v = vim.fn.expand(value)
      if is_java_home(v) then
        return v
      end
      local mv = major_version(v)
      if mv and is_java_home(home_map()[mv] or "") then
        return home_map()[mv]
      end
    end
  end

  -- 2) Common version files (asdf/jenv style)
  do
    local v = read_file(join(root_dir, ".java-version"))
    local mv = v and major_version(v)
    if mv and is_java_home(home_map()[mv] or "") then
      return home_map()[mv]
    end
  end

  do
    local tool_versions = read_file(join(root_dir, ".tool-versions"))
    if tool_versions then
      local v = tool_versions:match("\n?java%s+([^\n]+)")
      local mv = v and major_version(v)
      if mv and is_java_home(home_map()[mv] or "") then
        return home_map()[mv]
      end
    end
  end

  -- 3) Fall back to current environment
  if is_java_home(vim.env.JAVA_HOME or "") then
    return vim.env.JAVA_HOME
  end

  return nil
end

---@param root_dir string
---@return string
function M.root_hash(root_dir)
  local ok, hash = pcall(vim.fn.sha256, root_dir)
  if not ok or type(hash) ~= "string" then
    return "unknown"
  end
  return hash:sub(1, 8)
end

return M

