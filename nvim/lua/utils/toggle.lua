local M = {}

---@param silent boolean?
---@param values? {[1]:any, [2]:any}
function M.option(option, silent, values)
    if values then
        if vim.opt_local[option]:get() == values[1] then
            vim.opt_local[option] = values[2]
        else
            vim.opt_local[option] = values[1]
        end
        return require("utils").info("Set " .. option .. " to " .. vim.opt_local[option]:get(), { title = "Option" })
    end
    vim.opt_local[option] = not vim.opt_local[option]:get()
    if not silent then
        if vim.opt_local[option]:get() then
            require("utils").info("Enabled " .. option, { title = "Option" })
        else
            require("utils").warn("Disabled " .. option, { title = "Option" })
        end
    end
end

local nu = { number = true, relativenumber = true }
function M.number()
    if vim.opt_local.number:get() or vim.opt_local.relativenumber:get() then
        nu = { number = vim.opt_local.number:get(), relativenumber = vim.opt_local.relativenumber:get() }
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        require("utils").warn("Disabled line numbers", { title = "Option" })
    else
        vim.opt_local.number = nu.number
        vim.opt_local.relativenumber = nu.relativenumber
        require("utils").info("Enabled line numbers", { title = "Option" })
    end
end

function M.diagnostics()
    local enabled = vim.diagnostic.is_disabled()
    if enabled then
        vim.diagnostic.enable()
        require("utils").info("Enabled diagnostics", { title = "Diagnostics" })
    else
        vim.diagnostic.disable()
        require("utils").warn("Disabled diagnostics", { title = "Diagnostics" })
    end
end

---@param buf? number
---@param value? boolean
function M.inlay_hints(buf, value)
  local buffer = buf or vim.api.nvim_get_current_buf()
  
  -- Handle different Neovim versions and API changes
  if vim.lsp.inlay_hint then
    if vim.lsp.inlay_hint.enable then
      -- Modern API (Neovim 0.10+)
      local current = false
      
      -- Try to get current state safely
      local ok, is_enabled = pcall(vim.lsp.inlay_hint.is_enabled, { bufnr = buffer })
      if ok then
        current = is_enabled
      else
        -- Fallback: try with just buffer number
        local ok2, is_enabled2 = pcall(vim.lsp.inlay_hint.is_enabled, buffer)
        current = ok2 and is_enabled2 or false
      end
      
      local enable = value ~= nil and value or not current
      
      -- Enable/disable with proper parameters
      local success = pcall(vim.lsp.inlay_hint.enable, enable, { bufnr = buffer })
      if not success then
        -- Fallback to older API if new one fails
        pcall(vim.lsp.inlay_hint.enable, buffer, enable)
      end
      
      if not value then -- Only show message when toggling
        if enable then
          require("utils").info("Enabled inlay hints", { title = "LSP" })
        else
          require("utils").warn("Disabled inlay hints", { title = "LSP" })
        end
      end
    else
      -- Older API: vim.lsp.inlay_hint(bufnr, enable)
      local enable = value ~= nil and value or false
      pcall(vim.lsp.inlay_hint, buffer, enable)
    end
  elseif vim.lsp.buf.inlay_hint then
    -- Even older API
    pcall(vim.lsp.buf.inlay_hint, buffer, value)
  else
    -- No inlay hints support
    if not value then
      require("utils").warn("Inlay hints not supported in this Neovim version", { title = "LSP" })
    end
  end
end

setmetatable(M, {
    __call = function(m, ...)
        return m.option(...)
    end,
})

return M
