return {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    dependencies = {
        "williamboman/mason.nvim",
        "neovim/nvim-lspconfig",
        "mfussenegger/nvim-dap",
        "rcarriga/nvim-dap-ui",
    },
    config = function()
        local home = os.getenv("HOME")
        local jdtls_path = home .. "/.local/share/nvim/mason/packages/jdtls"
        local launcher_path = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
        local config_linux = jdtls_path .. "/config_linux"
        local lombok_path = home .. "/.m2/repository/org/projectlombok/lombok/1.18.38/lombok-1.18.38.jar"

        -- Detect JAVA_HOME
        local function detect_jdk()
            local java_home = os.getenv("JAVA_HOME")
            if java_home and #java_home > 0 then
                return java_home
            end
            local handle = io.popen("readlink -f $(which java) | sed 's:/bin/java::'")
            if handle then
                local result = handle:read("*a"):gsub("%s+$", "")
                handle:close()
                return result
            end
            return nil
        end

        local jdk_home = detect_jdk()
        if not jdk_home then
            vim.notify("No JDK detected! Please set JAVA_HOME.", vim.log.levels.ERROR)
            return
        end

        -- Workspace dir (per project)
        local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
        local workspace_dir = home .. "/.local/share/eclipse/" .. project_name

        -- Collect debug + test bundles
        local bundles = {
            vim.fn.glob(
                home
                    .. "/.local/share/nvim/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar"
            ),
        }
        vim.list_extend(
            bundles,
            vim.split(vim.fn.glob(home .. "/.local/share/nvim/mason/packages/java-test/extension/server/*.jar"), "\n")
        )

        -- Client capabilities with file operations (needed for some refactors)
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities.workspace = capabilities.workspace or {}
        capabilities.workspace.workspaceEdit = capabilities.workspace.workspaceEdit or {}
        capabilities.workspace.workspaceEdit.documentChanges = true
        capabilities.workspace.workspaceEdit.resourceOperations = { "create", "rename", "delete" }
        capabilities.workspace.didChangeWatchedFiles = { dynamicRegistration = true }
        capabilities.workspace.fileOperations = {
            dynamicRegistration = false,
            didCreate = true,
            didRename = true,
            didDelete = true,
            willCreate = true,
            willRename = true,
            willDelete = true,
        }

        local config = {
            cmd = {
                jdk_home .. "/bin/java",
                "-Declipse.application=org.eclipse.jdt.ls.core.id1",
                "-Dosgi.bundles.defaultStartLevel=4",
                "-Declipse.product=org.eclipse.jdt.ls.core.product",
                "-Dlog.protocol=true",
                "-Dlog.level=ALL",
                "-javaagent:" .. lombok_path,
                "-Xms1g",
                "--add-modules=ALL-SYSTEM",
                "--add-opens",
                "java.base/java.util=ALL-UNNAMED",
                "--add-opens",
                "java.base/java.lang=ALL-UNNAMED",
                "-jar",
                launcher_path,
                "-configuration",
                config_linux,
                "-data",
                workspace_dir,
            },
            capabilities = capabilities,
            root_dir = require("jdtls.setup").find_root({
                "mvnw",
                "gradlew",
                "pom.xml",
                "build.gradle",
            }),
            settings = {
                java = {
                    home = jdk_home,
                    eclipse = { downloadSources = true },
                    configuration = {
                        updateBuildConfiguration = "interactive",
                        runtimes = {
                            { name = "JavaSE-1.8", path = "/usr/lib/jvm/java-8-openjdk" },
                            { name = "JavaSE-11", path = "/usr/lib/jvm/java-11-openjdk" },
                            { name = "JavaSE-17", path = "/usr/lib/jvm/java-17-openjdk" },
                            { name = "JavaSE-19", path = "/usr/lib/jvm/java-19-openjdk" },
                            { name = "JavaSE-21", path = "/usr/lib/jvm/java-21-openjdk" },
                            { name = "JavaSE-24", path = "/usr/lib/jvm/java-24-openjdk" },
                            { name = "JavaSE-25", path = "/usr/lib/jvm/java-25-openjdk" },
                        },
                    },
                    maven = { downloadSources = true },
                    implementationsCodeLens = { enabled = true },
                    referencesCodeLens = { enabled = true },
                    references = { includeDecompiledSources = true },
                    format = { enabled = false }, -- use google-java-format
                    saveActions = { organizeImports = true },
                    completion = {
                        favoriteStaticMembers = {
                            "org.hamcrest.MatcherAssert.assertThat",
                            "org.hamcrest.Matchers.*",
                            "org.hamcrest.CoreMatchers.*",
                            "org.junit.jupiter.api.Assertions.*",
                            "java.util.Objects.requireNonNull",
                            "java.util.Objects.requireNonNullElse",
                            "org.mockito.Mockito.*"
                        },
                        importOrder = {
                            "java",
                            "javax",
                            "com",
                            "org"
                        },
                    },
                    sources = {
                        organizeImports = {
                            starThreshold = 9999,
                            staticStarThreshold = 9999,
                        },
                    },
                    codeGeneration = {
                        toString = {
                            template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
                        },
                        hashCodeEquals = {
                            useJava7Objects = true,
                        },
                        useBlocks = true,
                    },
                },
            },
            init_options = {
                bundles = bundles,
            },
        }

        -- Start jdtls
        require("jdtls").start_or_attach(config)

        -- Java-specific keymaps
        local opts = { noremap = true, silent = true }
        vim.keymap.set("n", "<leader>oi", "<cmd>JdtOrganizeImports<CR>", opts)
        vim.keymap.set("n", "<leader>ev", "<cmd>JdtExtractVariable<CR>", opts)
        vim.keymap.set("n", "<leader>ec", "<cmd>JdtExtractConstant<CR>", opts)
        vim.keymap.set("v", "<leader>em", "<Esc><Cmd>JdtExtractMethod<CR>", opts)

        -- Java refactoring commands
        vim.keymap.set("n", "<leader>jm", function()
            require("utils.java_refactor").move_class_to_package()
        end, { desc = "Move Java class to package" })

        vim.keymap.set("n", "<leader>jr", function()
            require("utils.java_refactor").rename_class()
        end, { desc = "Rename Java class" })

        -- Try using JDTLS commands if available
        vim.keymap.set("n", "<leader>jmp", function()
            -- First check if we have JDTLS available
            local clients = vim.lsp.get_active_clients({ name = "jdtls" })
            if #clients == 0 then
                vim.notify("JDTLS not active", vim.log.levels.WARN)
                return
            end

            -- Try different approaches for moving files
            local approaches = {
                -- Approach 1: Standard LSP code action for refactor.move
                function()
                    vim.lsp.buf.code_action({
                        context = { only = { "refactor.move" }, diagnostics = {} },
                    })
                end,
                -- Approach 2: Direct JDTLS command execution
                function()
                    local jdtls = require("jdtls")
                    local uri = vim.uri_from_bufnr(0)
                    jdtls.execute_command({
                        command = "java.action.moveFile",
                        arguments = { uri }
                    })
                end,
                -- Approach 3: Custom move class utility
                function()
                    require("utils.java_refactor").move_class_to_package()
                end,
            }

            -- Try each approach in order
            for i, approach in ipairs(approaches) do
                local success = pcall(approach)
                if success then
                    vim.notify("Used approach " .. i .. " for moving file", vim.log.levels.INFO)
                    break
                elseif i == #approaches then
                    vim.notify("All move approaches failed, falling back to custom utility", vim.log.levels.WARN)
                    require("utils.java_refactor").move_class_to_package()
                end
            end
        end, { desc = "Move Java class (Multiple approaches)" })


        -- Test runner mappings
        vim.keymap.set("n", "<leader>tc", "<cmd>lua require'jdtls'.test_class()<CR>", opts)
        vim.keymap.set("n", "<leader>tm", "<cmd>lua require'jdtls'.test_nearest_method()<CR>", opts)
        vim.keymap.set("n", "<leader>td", "<cmd>lua require'jdtls'.pick_test()<CR>", opts)

        -- Setup DAP UI
        local dap = require("dap")
        local dapui = require("dapui")
        dapui.setup()

        dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
        end

        -- Filter noisy diagnostics
        require("plugins.lsp.configs.lsp-diagnostics").filter_java()
    end,
}
