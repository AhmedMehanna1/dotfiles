local M = {}

-- Common auto-format setup for ftplugin files
function M.setup_auto_format(opts)
    opts = opts or {}
    local timeout = opts.timeout_ms or 500

    vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = 0,
        callback = function()
            require("conform").format({
                timeout_ms = timeout,
                lsp_fallback = true,
            })
        end,
    })
end

-- Setup common indentation
function M.setup_indent(width)
    vim.opt_local.shiftwidth = width
    vim.opt_local.tabstop = width
    vim.opt_local.expandtab = true
end

return M
