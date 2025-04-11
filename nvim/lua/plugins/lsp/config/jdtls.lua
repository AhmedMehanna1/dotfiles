function start_jdtls()
    local jdtls = require("jdtls")
    local home = os.getenv("HOME")
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
    local workspace_dir = home .. "/.local/share/jdtls-workspace/" .. project_name

    -- Find the root directory of the project (e.g., where pom.xml or build.gradle is located)
    local root_markers = { "pom.xml", "build.gradle", "gradlew", "mvnw" }
    local root_dir = require("jdtls.setup").find_root(root_markers)

    if not root_dir then
        vim.notify("Could not find Java project root. Skipping jdtls setup.", vim.log.levels.WARN)
        return
    end

    local function get_lombok_version_maven(root_dir)
        local pom_path = root_dir .. "/pom.xml"
        if vim.fn.filereadable(pom_path) == 0 then
            return nil
        end

        -- Read the pom.xml file
        local pom_content = vim.fn.readfile(pom_path)
        local in_lombok_dependency = false

        for _, line in ipairs(pom_content) do
            -- Check if we are inside the Lombok dependency block
            if line:match([[<groupId>org%.projectlombok</groupId>]]) then
                in_lombok_dependency = true
            elseif in_lombok_dependency and line:match([[</dependency>]]) then
                -- Exit the Lombok dependency block
                break
            elseif in_lombok_dependency then
                -- Match the version tag
                local match = line:match([[<version>(%d+%.%d+%.%d+)</version>]])
                if match then
                    return match
                end
            end
        end

        return nil
    end

    local function get_lombok_path()
        -- Try to detect the build system
        local lombok_version = get_lombok_version_maven(root_dir)

        if not lombok_version then
            vim.notify("Could not determine Lombok version. Using default.", vim.log.levels.WARN)
            lombok_version = "1.18.34" -- Default version
        end

        -- Construct the Lombok path
        return string.format(
            "%s/.m2/repository/org/projectlombok/lombok/%s/lombok-%s.jar",
            home,
            lombok_version,
            lombok_version
        )
    end

    -- Path to Lombok jar (adjust based on your installation)
    -- Get Lombok path
    local lombok_path = get_lombok_path()
    if not vim.fn.filereadable(lombok_path) then
        vim.notify("Lombok jar not found at " .. lombok_path, vim.log.levels.ERROR)
        return
    end

    vim.notify(home, vim.log.levels.INFO)
    vim.notify(project_name, vim.log.levels.INFO)
    vim.notify(workspace_dir, vim.log.levels.INFO)
    vim.notify(workspace_dir, vim.log.levels.INFO)
    vim.notify(root_dir, vim.log.levels.INFO)

    -- Configuration for jdtls
    local config = {
        cmd = {
            home .. "/.dotfiles/java-lsp/bin/jdtls", -- Path to Java executable
            "-javaagent:" .. lombok_path, -- Add Lombok agent
            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
            "-Dosgi.bundles.defaultStartLevel=4",
            "-Declipse.product=org.eclipse.jdt.ls.core.product",
            -- "-Dlog.protocol=true",
            "-Dlog.level=ALL",
            "-Xms1g",
            "--add-modules=ALL-SYSTEM",
            "--add-opens java.base/java.util=ALL-UNNAMED",
            "--add-opens java.base/java.lang=ALL-UNNAMED",
            "-jar " .. home .. "/.dotfiles/java-lsp/plugins/org.eclipse.equinox.launcher_*.jar",
            "-configuration " .. home .. "/.dotfiles/java-lsp/config_linux", -- Adjust based on OS (e.g., config_mac, config_win)
            "-data " .. workspace_dir,
        },
        root_dir = root_dir,
        settings = {
            java = {
                eclipse = {
                    downloadSources = true,
                },
                configuration = {
                    updateBuildConfiguration = "interactive",
                },
                maven = {
                    downloadSources = true,
                },
                implementationsCodeLens = {
                    enabled = true,
                },
                referencesCodeLens = {
                    enabled = true,
                },
            },
        },
        init_options = {
            bundles = {},
        },
    }

    -- Start jdtls
    jdtls.start_or_attach(config)

    -- Keybindings
    local opts = { noremap = true, silent = true }
    vim.api.nvim_buf_set_keymap(0, "n", "<leader>co", "<cmd>lua require('jdtls').organize_imports()<CR>", opts)
    vim.api.nvim_buf_set_keymap(0, "n", "<leader>cv", "<cmd>lua require('jdtls').extract_variable()<CR>", opts)
    vim.api.nvim_buf_set_keymap(0, "v", "<leader>cm", "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", opts)
end

-- Autocommand to trigger jdtls only for Java files
vim.api.nvim_create_autocmd("FileType", {
    pattern = "java",
    callback = function()
        start_jdtls()
    end,
})
