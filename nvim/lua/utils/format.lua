local M = {}

M.formatters = {}

function M.register(formatter)
    M.formatters[#M.formatters + 1] = formatter
    table.sort(M.formatters, function(a, b)
        return a.priority > b.priority
    end)
end

function M.resolve(buf)
    buf = buf or vim.api.nvim_get_current_buf()
    local have_primary = false
    for _, formatter in ipairs(M.formatters) do
        if formatter.sources then
            for _, source in ipairs(formatter.sources(buf)) do
                local available = source.available and source.available(buf)
                if available == nil then
                    available = true
                end
                if available then
                    return {
                        formatter = formatter,
                        sources = { source },
                        primary = not have_primary,
                    }
                end
            end
        end
    end
end

function M.info(buf)
    buf = buf or vim.api.nvim_get_current_buf()
    local ret = M.resolve(buf) or {}
    return ret
end

---@param opts? {force?:boolean}
function M.format(opts)
    opts = opts or {}
    local buf = vim.api.nvim_get_current_buf()
    local info = M.resolve(buf)
    if not info then
        return
    end

    return info.formatter.format(buf)
end

function M.health()
    local Config = require("utils")
    local health = vim.health or require("health")

    health.report_start("lazyvim.format")
    local buf = vim.api.nvim_get_current_buf()
    local info = M.info(buf)
    if not info.formatter then
        health.report_warn("no formatters available for this buffer")
    else
        health.report_ok(("Using **%s**"):format(info.formatter.name))
    end
end

vim.api.nvim_create_user_command("LazyFormat", function()
    M.format({ force = true })
end, { desc = "Format selection or buffer" })

vim.api.nvim_create_user_command("LazyFormatInfo", function()
    M.info()
end, { desc = "Show info about current formatters" })

return M
