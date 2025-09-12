return {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
        local home = os.getenv("HOME")
        local jdtls_path = home .. "/.local/share/nvim/mason/packages/jdtls"
        local launcher_path = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
        local config_linux = jdtls_path .. "/config_linux"
        local lombok_path = "/home/ahmed-mehanna/.m2/repository/org/projectlombok/lombok/1.18.38/lombok-1.18.38.jar"

        -- Pick the right Java version automatically
        local function detect_jdk()
            local java_home = os.getenv("JAVA_HOME")
            if java_home and #java_home > 0 then
                return java_home
            end
            -- fallback: use `java` from PATH
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

        -- Workspace directory (one per project)
        local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
        local workspace_dir = home .. "/.local/share/eclipse/" .. project_name

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
            root_dir = require("jdtls.setup").find_root({ "mvnw", "gradlew", "pom.xml", "build.gradle" }),
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
                    format = { enabled = false },
                    saveActions = { organizeImports = true },
                },
            },
            init_options = {
                bundles = {
                    vim.fn.glob(
                        home
                            .. "/.local/share/nvim/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar"
                    ),
                },
            },
        }

        -- Attach nvim-jdtls
        require("jdtls").start_or_attach(config)

        -- Keymaps
        local opts = { noremap = true, silent = true }
        vim.keymap.set("n", "<leader>oi", "<cmd>JdtOrganizeImports<CR>", opts)
        vim.keymap.set("n", "<leader>ev", "<cmd>JdtExtractVariable<CR>", opts)
        vim.keymap.set("n", "<leader>ec", "<cmd>JdtExtractConstant<CR>", opts)
        vim.keymap.set("v", "<leader>em", "<Esc><Cmd>JdtExtractMethod<CR>", opts)
    end,
}
