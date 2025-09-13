-- Comprehensive Java LSP fix to ensure JDTLS attaches to all Java files

local M = {}

-- Track JDTLS state
local jdtls_state = {
    initialized = false,
    workspace_root = nil,
}

-- Function to ensure JDTLS is attached to a buffer
local function ensure_jdtls_attached(buf)
    if vim.bo[buf].filetype ~= "java" then
        return
    end

    -- Check if JDTLS is already attached to this buffer
    local clients = vim.lsp.get_active_clients({ bufnr = buf })
    for _, client in ipairs(clients) do
        if client.name == "jdtls" then
            return -- Already attached
        end
    end

    -- JDTLS not attached, try to attach it
    local jdtls_clients = vim.lsp.get_active_clients({ name = "jdtls" })

    if #jdtls_clients > 0 then
        -- JDTLS is running, attach it to this buffer
        local client = jdtls_clients[1]
        local success = vim.lsp.buf_attach_client(buf, client.id)

        if success then
            vim.notify("🔧 Manually attached JDTLS to " .. vim.api.nvim_buf_get_name(buf), vim.log.levels.INFO)
        end
    else
        -- No JDTLS client running at all
        vim.notify("⚠️  JDTLS not running. Restart Neovim or use :JavaLspRestart", vim.log.levels.WARN)
    end
end

-- Setup function
function M.setup()
    -- Autocmd to ensure JDTLS attaches to all Java files
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "BufReadPost" }, {
        pattern = "*.java",
        callback = function(args)
            local buf = args.buf

            -- Wait a bit for nvim-java to do its thing first
            vim.defer_fn(function()
                ensure_jdtls_attached(buf)
            end, 1500)
        end,
        desc = "Ensure JDTLS is attached to Java files"
    })

    -- Additional autocmd for when switching between buffers
    vim.api.nvim_create_autocmd("BufEnter", {
        callback = function(args)
            local buf = args.buf

            if vim.bo[buf].filetype == "java" then
                -- Delay check to allow LSP to attach naturally first
                vim.defer_fn(function()
                    ensure_jdtls_attached(buf)
                end, 2000)
            end
        end,
        desc = "Check JDTLS attachment on buffer enter"
    })

    -- Override the save function to ensure LSP is attached before save
    vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.java",
        callback = function(args)
            local buf = args.buf
            ensure_jdtls_attached(buf)

            -- Small delay to allow attachment before save
            vim.defer_fn(function()
                -- Check if any formatting is configured
                local clients = vim.lsp.get_active_clients({ bufnr = buf })
                for _, client in ipairs(clients) do
                    if client.name == "jdtls" and client.supports_method("textDocument/formatting") then
                        vim.lsp.buf.format({ bufnr = buf })
                        break
                    end
                end
            end, 100)
        end,
        desc = "Ensure JDTLS is attached before save"
    })

    -- Create helpful user commands
    vim.api.nvim_create_user_command("JavaFixAttach", function()
        local buf = vim.api.nvim_get_current_buf()
        ensure_jdtls_attached(buf)
    end, { desc = "Force attach JDTLS to current buffer" })

    vim.api.nvim_create_user_command("JavaCheckAll", function()
        local buffers = vim.api.nvim_list_bufs()
        local java_buffers = {}

        for _, buf in ipairs(buffers) do
            if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "java" then
                table.insert(java_buffers, buf)
            end
        end

        print(string.format("Found %d Java buffers", #java_buffers))

        for _, buf in ipairs(java_buffers) do
            local clients = vim.lsp.get_active_clients({ bufnr = buf })
            local attached = false
            for _, client in ipairs(clients) do
                if client.name == "jdtls" then
                    attached = true
                    break
                end
            end

            local bufname = vim.api.nvim_buf_get_name(buf)
            local filename = vim.fn.fnamemodify(bufname, ":t")

            if attached then
                print(string.format("✅ %s - JDTLS attached", filename))
            else
                print(string.format("❌ %s - JDTLS NOT attached", filename))
                ensure_jdtls_attached(buf)
            end
        end
    end, { desc = "Check JDTLS attachment for all Java buffers" })
end

return M