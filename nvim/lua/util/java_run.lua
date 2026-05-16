local M = {}

local java = require("util.java")

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
  return text ~= "" and text or nil
end

---@param path string
---@param obj table
---@return boolean ok
local function write_json(path, obj)
  local encoded = vim.json.encode(obj)
  local dir = vim.fn.fnamemodify(path, ":h")
  vim.fn.mkdir(dir, "p")
  local ok = pcall(vim.fn.writefile, { encoded }, path)
  return ok
end

---@param path string
---@return table|nil
local function read_json(path)
  local text = read_file(path)
  if not text then
    return nil
  end
  local ok, decoded = pcall(vim.json.decode, text)
  if not ok or type(decoded) ~= "table" then
    return nil
  end
  return decoded
end

---@param root string
---@return string repo_path, string local_path
local function config_paths(root)
  local repo_path = root .. "/.nvim/java-run.json"
  local local_dir = vim.fn.stdpath("state") .. "/java-run"
  local local_path = local_dir .. "/" .. java.root_hash(root) .. ".json"
  return repo_path, local_path
end

---@param root string
---@return table cfg, string path
function M.load(root)
  local repo_path, local_path = config_paths(root)
  local cfg = read_json(repo_path)
  if cfg then
    return cfg, repo_path
  end
  cfg = read_json(local_path)
  if cfg then
    return cfg, local_path
  end
  return {
    tool = "maven", -- or "gradle"
    module = "",
    goal = "spring-boot:run", -- maven
    task = "bootRun", -- gradle
    env = {},
  }, repo_path
end

---@param root string
---@param cfg table
---@param preferred_path string
---@return string path
function M.save(root, cfg, preferred_path)
  local repo_path, local_path = config_paths(root)
  local target = preferred_path or repo_path

  -- Prefer repo config, but fall back to local if not writable
  if target == repo_path then
    local dir = vim.fn.fnamemodify(repo_path, ":h")
    if vim.fn.filewritable(dir) ~= 2 and vim.fn.filewritable(repo_path) ~= 1 then
      target = local_path
    end
  end

  if not write_json(target, cfg) then
    -- last resort
    write_json(local_path, cfg)
    return local_path
  end
  return target
end

---@param root string
---@return string[]
local function find_maven_modules(root)
  local pom = root .. "/pom.xml"
  local text = read_file(pom)
  if not text then
    return {}
  end
  local modules = {}
  for mod in text:gmatch("<module>%s*([^<]+)%s*</module>") do
    mod = vim.trim(mod)
    if mod ~= "" then
      table.insert(modules, mod)
    end
  end
  return modules
end

---@param root string
---@param cb fun(root: string, cfg: table, saved_path: string)
function M.configure(root, cb)
  local cfg, path = M.load(root)

  local function pick_tool(next_fn)
    vim.ui.select({ "maven", "gradle" }, {
      prompt = "Build tool",
      format_item = function(item)
        return item
      end,
    }, function(choice)
      if not choice then
        return
      end
      cfg.tool = choice
      next_fn()
    end)
  end

  local function pick_module(next_fn)
    local modules = find_maven_modules(root)
    local items = { "(root)" }
    for _, m in ipairs(modules) do
      table.insert(items, m)
    end
    vim.ui.select(items, { prompt = "Module to run" }, function(choice)
      if not choice then
        return
      end
      cfg.module = choice == "(root)" and "" or choice
      next_fn()
    end)
  end

  local function input_goal(next_fn)
    if cfg.tool == "maven" then
      vim.ui.input({ prompt = "Maven goal", default = cfg.goal or "spring-boot:run" }, function(value)
        if value then
          cfg.goal = vim.trim(value)
        end
        next_fn()
      end)
    else
      vim.ui.input({ prompt = "Gradle task", default = cfg.task or "bootRun" }, function(value)
        if value then
          cfg.task = vim.trim(value)
        end
        next_fn()
      end)
    end
  end

  local function input_env(next_fn)
    local env_json = vim.json.encode(cfg.env or {})
    vim.ui.input({
      prompt = "Env as JSON (empty for none)",
      default = env_json,
    }, function(value)
      if value and vim.trim(value) ~= "" then
        local ok, decoded = pcall(vim.json.decode, value)
        if ok and type(decoded) == "table" then
          cfg.env = decoded
        else
          vim.notify("Invalid JSON; keeping previous env", vim.log.levels.WARN)
        end
      else
        cfg.env = {}
      end
      next_fn()
    end)
  end

  pick_tool(function()
    pick_module(function()
      input_goal(function()
        input_env(function()
          local saved_path = M.save(root, cfg, path)
          if cb then
            cb(root, cfg, saved_path)
          end
        end)
      end)
    end)
  end)
end

---@param root string
---@param cfg table
local function run_in_terminal(root, cfg)
  local cmd
  if cfg.tool == "gradle" then
    local prefix = "./gradlew"
    if vim.fn.filereadable(root .. "/gradlew") ~= 1 then
      prefix = "gradle"
    end
    if cfg.module and cfg.module ~= "" then
      local mod = cfg.module:gsub("/", ":")
      cmd = string.format("%s :%s:%s", prefix, mod, cfg.task or "bootRun")
    else
      cmd = string.format("%s %s", prefix, cfg.task or "bootRun")
    end
  else
    local prefix = "./mvnw"
    if vim.fn.filereadable(root .. "/mvnw") ~= 1 then
      prefix = "mvn"
    end
    if cfg.module and cfg.module ~= "" then
      cmd = string.format("%s -pl %s -am %s", prefix, vim.fn.shellescape(cfg.module), cfg.goal or "spring-boot:run")
    else
      cmd = string.format("%s %s", prefix, cfg.goal or "spring-boot:run")
    end
  end

  local env = cfg.env or {}
  local java_home = java.detect_java_home(root)
  if java_home then
    env = vim.tbl_deep_extend("force", env, {
      JAVA_HOME = java_home,
      PATH = java_home .. "/bin:" .. (vim.env.PATH or ""),
    })
  end

  if vim.g.snacks_terminal ~= false and pcall(function()
    local curwin = vim.api.nvim_get_current_win()
    Snacks.terminal.open(cmd, {
      cwd = root,
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

  -- fallback: built-in terminal split
  vim.cmd("botright split | resize 15")
  vim.fn.termopen(cmd, { cwd = root, env = env })
  vim.cmd.startinsert()
end

---@param root string
function M.run(root)
  local cfg = M.load(root)
  run_in_terminal(root, cfg)
end

return M
