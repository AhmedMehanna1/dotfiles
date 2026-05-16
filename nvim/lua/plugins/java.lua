return {
    -- Per-project env (useful for switching JAVA_HOME via .envrc)
    {
        "direnv/direnv.vim",
        event = "VeryLazy",
        init = function()
            vim.g.direnv_silent_load = 1
        end,
    },

    -- Customize LazyVim's Java (nvim-jdtls) setup:
    -- - unique workspace per root (avoids collisions when multiple services share a name)
    -- - per-project JAVA_HOME detection (.nvim/java-home, .java-version, .tool-versions, or env)
    {
        "mfussenegger/nvim-jdtls",
        opts = function(_, opts)
            local java = require("util.java")

            local base_project_name = opts.project_name
            opts.project_name = function(root_dir)
                local name = base_project_name(root_dir)
                if not name or not root_dir then
                    return name
                end
                return name .. "-" .. java.root_hash(root_dir)
            end

            opts.jdtls = function(config)
                local java_home = java.detect_java_home(config.root_dir)
                if java_home then
                    config.cmd_env = config.cmd_env or {}
                    config.cmd_env.JAVA_HOME = java_home
                    local path = config.cmd_env.PATH or vim.env.PATH or ""
                    config.cmd_env.PATH = java_home .. "/bin:" .. path
                end
                return config
            end

            opts.settings = vim.tbl_deep_extend("force", opts.settings or {}, {
                java = {
                    configuration = {
                        updateBuildConfiguration = "interactive",
                    },
                    import = {
                        gradle = {
                            enabled = true,
                        },
                        maven = {
                            enabled = true,
                        },
                    },
                    format = {
                        settings = {
                            -- IntelliJ-exported Eclipse formatter profile
                            url = vim.uri_from_fname(
                                vim.fn.stdpath("config") .. "/lua/config/formatters/jetbrains-java.xml"
                            ),
                            profile = "Default",
                        },
                    },
                },
            })
        end,
    },

    -- Simple commands for multi-service workspaces + build tools
    {
        "LazyVim/LazyVim",
        opts = function()
            local function root()
                return LazyVim.root()
            end

            vim.api.nvim_create_user_command("ProjectTab", function(cmd)
                require("util.workspace").tab_project(cmd.args)
            end, { nargs = 1, complete = "dir" })

            vim.api.nvim_create_user_command("ProjectTabsFromFile", function(cmd)
                require("util.workspace").tabs_from_file(cmd.args)
            end, { nargs = 1, complete = "file" })

            vim.api.nvim_create_user_command("Mvn", function(cmd)
                require("util.workspace").run("mvn " .. cmd.args)
            end, { nargs = "*", complete = "file" })

            vim.api.nvim_create_user_command("Mvnw", function(cmd)
                require("util.workspace").run("./mvnw " .. cmd.args)
            end, { nargs = "*", complete = "file" })

            vim.api.nvim_create_user_command("Gradle", function(cmd)
                require("util.workspace").run("gradle " .. cmd.args)
            end, { nargs = "*", complete = "file" })

            vim.api.nvim_create_user_command("Gradlew", function(cmd)
                require("util.workspace").run("./gradlew " .. cmd.args)
            end, { nargs = "*", complete = "file" })

            vim.api.nvim_create_user_command("JavaRunConfig", function()
                require("util.java_run").configure(root(), function(_, _, saved_path)
                    vim.notify("Saved Java run config: " .. saved_path, vim.log.levels.INFO)
                end)
            end, { desc = "Configure Java run profile for this project" })

            vim.api.nvim_create_user_command("JavaRun", function()
                require("util.java_run").run(root())
            end, { desc = "Run Java project (configured)" })
        end,
    },

    -- Always format Java via JDTLS using the IntelliJ-exported profile.

    {
        "folke/which-key.nvim",
        optional = true,
        keys = {
            {
                "<leader>xc",
                function()
                    vim.cmd("JavaRunConfig")
                end,
                desc = "Java Run Config",
            },
            {
                "<leader>xr",
                function()
                    vim.cmd("JavaRun")
                end,
                desc = "Java Run",
            },
        },
    },
}
