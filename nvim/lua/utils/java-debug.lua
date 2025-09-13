local M = {}

function M.check_java_lsp()
    print("=== Java LSP Debug Information ===")

    -- Check current buffer
    local buf = vim.api.nvim_get_current_buf()
    local bufname = vim.api.nvim_buf_get_name(buf)
    local filetype = vim.bo[buf].filetype

    print("Current buffer:", bufname)
    print("File type:", filetype)

    -- Check active LSP clients
    local clients = vim.lsp.get_active_clients({ bufnr = buf })
    print("Active LSP clients for current buffer:", #clients)

    for i, client in ipairs(clients) do
        print(string.format("  %d. %s (id: %d)", i, client.name, client.id))
    end

    -- Check all active LSP clients
    local all_clients = vim.lsp.get_active_clients()
    print("All active LSP clients:", #all_clients)

    for i, client in ipairs(all_clients) do
        print(string.format("  %d. %s (id: %d)", i, client.name, client.id))
    end

    -- Check for JDTLS specifically
    local jdtls_clients = vim.lsp.get_active_clients({ name = "jdtls" })
    print("JDTLS clients:", #jdtls_clients)

    -- Check workspace folders
    if #jdtls_clients > 0 then
        local workspace_folders = jdtls_clients[1].config.workspace_folders
        if workspace_folders then
            print("Workspace folders:")
            for i, folder in ipairs(workspace_folders) do
                print(string.format("  %d. %s", i, folder.name))
            end
        else
            print("No workspace folders configured")
        end
    end

    -- Check root directory
    local root_dir = vim.lsp.buf.list_workspace_folders()
    print("Workspace folders from buf:", vim.inspect(root_dir))

    -- Check if nvim-java is properly loaded
    local java_ok, java = pcall(require, "java")
    print("nvim-java loaded:", java_ok)

    if java_ok then
        -- You can add more specific nvim-java debugging here
        print("nvim-java available")
    end

    print("=== End Debug Information ===")
end

function M.restart_java_lsp()
    print("Restarting Java LSP...")

    -- Stop all Java-related LSP clients
    local clients = vim.lsp.get_active_clients({ name = "jdtls" })
    for _, client in ipairs(clients) do
        print("Stopping client:", client.name)
        client.stop()
    end

    -- Clear LSP caches and restart
    vim.defer_fn(function()
        print("Attempting to restart Java LSP...")

        -- Force reload nvim-java
        package.loaded["java"] = nil
        local ok, java = pcall(require, "java")

        if ok then
            -- Try to setup again
            vim.defer_fn(function()
                print("Java module reloaded, attempting setup...")

                -- If current buffer is Java, try to reattach
                if vim.bo.filetype == "java" then
                    local buf = vim.api.nvim_get_current_buf()

                    -- Wait a bit more and check if LSP attached
                    vim.defer_fn(function()
                        local new_clients = vim.lsp.get_active_clients({ bufnr = buf })
                        local attached = false

                        for _, client in ipairs(new_clients) do
                            if client.name == "jdtls" then
                                attached = true
                                break
                            end
                        end

                        if attached then
                            print("✅ Java LSP successfully reattached!")
                        else
                            print("❌ Java LSP still not attached. Try restarting Neovim.")
                            print("💡 Make sure you're in a Java project with pom.xml or build.gradle")
                        end
                    end, 2000)
                end
            end, 500)
        else
            print("❌ Failed to reload nvim-java module")
        end
    end, 1000)
end

-- Function to force attach JDTLS to current buffer
function M.force_attach()
    local buf = vim.api.nvim_get_current_buf()

    if vim.bo[buf].filetype ~= "java" then
        print("Current buffer is not a Java file")
        return
    end

    local clients = vim.lsp.get_active_clients({ name = "jdtls" })
    if #clients == 0 then
        print("No JDTLS clients running. Use :JavaLspRestart first.")
        return
    end

    local client = clients[1]
    local success = vim.lsp.buf_attach_client(buf, client.id)

    if success then
        print("✅ Manually attached JDTLS to current buffer")
    else
        print("❌ Failed to attach JDTLS to current buffer")
    end
end

-- Create user commands for easy access
vim.api.nvim_create_user_command("JavaLspDebug", M.check_java_lsp, { desc = "Debug Java LSP status" })
vim.api.nvim_create_user_command("JavaLspRestart", M.restart_java_lsp, { desc = "Restart Java LSP" })
vim.api.nvim_create_user_command("JavaLspAttach", M.force_attach, { desc = "Force attach JDTLS to current buffer" })

return M