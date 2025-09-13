return {
    "nvim-java/nvim-java",
    ft = { "java" }, -- Load only for Java files
    dependencies = {
        "nvim-java/lua-async-await",
        "nvim-java/nvim-java-core",
        "nvim-java/nvim-java-test",
        "nvim-java/nvim-java-dap",
        "MunifTanjim/nui.nvim",
        "neovim/nvim-lspconfig",
        "mfussenegger/nvim-dap",
        {
            "williamboman/mason.nvim",
            opts = {
                registries = {
                    "github:nvim-java/mason-registry",
                    "github:mason-org/mason-registry",
                },
            },
        },
    },
    config = function()
        require("java").setup({
            root_markers = {
                "settings.gradle",
                "settings.gradle.kts",
                "pom.xml",
                "build.gradle",
                "mvnw",
                "gradlew",
                "build.gradle.kts",
                ".git",
            },
            java_test = {
                enable = true,
            },
            java_debug_adapter = {
                enable = true,
            },
            spring_boot_tools = {
                enable = true,
            },
            jdk = {
                auto_install = true,
            },
            notifications = {
                dap = true,
            },
            -- Enhanced configuration for stability
            verification = {
                invalid_order = false, -- Disable to avoid conflicts
                duplicate_setup_calls = false, -- Disable to avoid conflicts
                invalid_mason_registry = true,
            },
            -- Ensure JDTLS works properly
            lsp = {
                -- Auto-attach to all Java files in the workspace
                auto_attach = true,
            },
        })

        -- Force JDTLS to attach to Java files that might be missed
        vim.api.nvim_create_autocmd("BufReadPost", {
            pattern = "*.java",
            callback = function(args)
                local buf = args.buf

                -- Check if we're in a Java project
                local root = vim.fn.findfile("pom.xml", ".;")
                local gradle_root = vim.fn.findfile("build.gradle", ".;")
                local gradle_kts_root = vim.fn.findfile("build.gradle.kts", ".;")

                if root ~= "" or gradle_root ~= "" or gradle_kts_root ~= "" then
                    -- We're in a Java project, ensure JDTLS is running
                    vim.defer_fn(function()
                        local clients = vim.lsp.get_active_clients({ name = "jdtls" })
                        if #clients == 0 then
                            -- Try to start JDTLS by requiring java again
                            pcall(require, "java")
                        end
                    end, 500)
                end
            end,
        })
    end,
}
