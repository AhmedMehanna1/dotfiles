local M = {}

---@return number|nil winid
local function find_terminal_win()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == "terminal" or vim.bo[buf].filetype == "snacks_terminal" then
      return win
    end
  end
  return nil
end

---@param cmd string|string[]
local function term(cmd, opts)
  opts = opts or {}
  local cwd = opts.cwd or vim.uv.cwd()
  local env = opts.env

  if vim.g.snacks_terminal ~= false and pcall(function()
    local curwin = vim.api.nvim_get_current_win()
    Snacks.terminal.open(cmd, {
      cwd = cwd,
      env = env,
      interactive = true,
      auto_insert = false,
      win = {
        position = "bottom",
        height = 15,
      },
    })
    vim.schedule(function()
      if vim.api.nvim_win_is_valid(curwin) then
        pcall(vim.api.nvim_set_current_win, curwin)
      end
    end)
  end) then
    return
  end

  vim.cmd("botright split | resize 15")
  vim.fn.termopen(cmd, { cwd = cwd, env = env })
end

function M.focus_terminal()
  local win = find_terminal_win()
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_set_current_win(win)
    return true
  end
  return false
end

---@param path string
function M.tab_project(path)
  if not path or path == "" then
    return
  end
  path = vim.fn.expand(path)
  if vim.fn.isdirectory(path) ~= 1 then
    vim.notify("Not a directory: " .. path, vim.log.levels.WARN)
    return
  end
  vim.cmd("tabnew")
  vim.cmd("tcd " .. vim.fn.fnameescape(path))
  local ok, telescope = pcall(require, "telescope")
  if ok then
    pcall(telescope.extensions.file_browser.file_browser, {
      path = path,
      cwd = path,
      hidden = true,
      grouped = true,
      previewer = false,
      initial_mode = "normal",
      layout_config = { height = 30 },
    })
  end
end

---@param file string
function M.tabs_from_file(file)
  file = vim.fn.expand(file)
  if vim.fn.filereadable(file) ~= 1 then
    vim.notify("File not found: " .. file, vim.log.levels.WARN)
    return
  end
  local ok, lines = pcall(vim.fn.readfile, file)
  if not ok or not lines then
    return
  end
  local base = vim.fn.fnamemodify(file, ":h")
  for _, line in ipairs(lines) do
    local p = vim.trim((line or ""):gsub("\r", ""))
    if p ~= "" and not p:match("^#") then
      if not p:match("^/") then
        p = base .. "/" .. p
      end
      M.tab_project(p)
    end
  end
end

---@param cmdline string
function M.run(cmdline, opts)
  if not cmdline or cmdline == "" then
    return
  end
  term(cmdline, opts)
end

return M
