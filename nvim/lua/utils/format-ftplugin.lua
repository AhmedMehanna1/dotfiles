-- lua/utils/format-ftplugin.lua
local M = {}

-- Setup auto-format on save for the current buffer
function M.setup_auto_format(opts)
    opts = opts or {}
    local timeout = opts.timeout_ms or 500
    local lsp_fallback = opts.lsp_fallback ~= false -- default = true

    -- Clear existing autocmds for this buffer to avoid duplicates
    local group = vim.api.nvim_create_augroup("ConformFormat_" .. vim.api.nvim_get_current_buf(), { clear = true })

    vim.api.nvim_create_autocmd("BufWritePre", {
        group = group,
        buffer = 0,
        callback = function()
            require("conform").format({
                timeout_ms = timeout,
                lsp_fallback = lsp_fallback,
            })
        end,
    })
end

-- Setup indentation for the current buffer
function M.setup_indent(width, expandtab)
    expandtab = expandtab ~= false -- default = true
    vim.opt_local.shiftwidth = width
    vim.opt_local.tabstop = width
    vim.opt_local.expandtab = expandtab
end

return M
