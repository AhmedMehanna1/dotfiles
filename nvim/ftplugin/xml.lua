-- Read indentation settings for pom.xml from nearest .clang-format
-- Applies only to files named exactly "pom.xml"

local filename = vim.fn.expand("%:t")
if filename ~= "pom.xml" then
  return
end

-- Find nearest .clang-format (or _clang-format)
local function find_clang_format()
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname == "" then
    return nil
  end
  local start = vim.fs.dirname(bufname)
  local found = vim.fs.find({ ".clang-format", "_clang-format" }, { path = start, upward = true })
  return found and found[1] or nil
end

-- Parse minimal keys from .clang-format
local function parse_clang_format(path)
  local cfg = { }
  local ok, fh = pcall(io.open, path, "r")
  if not ok or not fh then
    return cfg
  end
  for line in fh:lines() do
    -- Trim comments
    line = line:gsub("#.*$", "")
    -- IndentWidth: 2
    local iw = line:match("%f[%w]IndentWidth:%s*(%d+)")
    if iw and not cfg.IndentWidth then
      cfg.IndentWidth = tonumber(iw)
    end
    -- TabWidth: 4
    local tw = line:match("%f[%w]TabWidth:%s*(%d+)")
    if tw and not cfg.TabWidth then
      cfg.TabWidth = tonumber(tw)
    end
    -- UseTab: Never|Always|ForIndentation|Smart
    local ut = line:match("%f[%w]UseTab:%s*([%a]+)")
    if ut and not cfg.UseTab then
      cfg.UseTab = ut
    end
  end
  fh:close()
  return cfg
end

local cfg_path = find_clang_format()
if not cfg_path then
  return
end

local cfg = parse_clang_format(cfg_path)
if not cfg then
  return
end

-- Decide indentation settings
local width = cfg.IndentWidth or cfg.TabWidth
if width then
  vim.opt_local.shiftwidth = width
  vim.opt_local.tabstop = cfg.TabWidth or width
end

-- Decide tabs vs spaces
if cfg.UseTab then
  local ut = cfg.UseTab
  if ut == "Never" then
    vim.opt_local.expandtab = true
  elseif ut == "Always" or ut == "ForIndentation" then
    vim.opt_local.expandtab = false
  end
end

