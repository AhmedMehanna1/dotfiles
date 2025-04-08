return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local lint = require("lint")

        lint.linters_by_ft = {
            javascript = { "eslint_d" },
            typescript = { "eslint_d" },
            javascriptreact = { "eslint_d" },
            typescriptreact = { "eslint_d" },
            svelte = { "eslint_d" },
            python = { "pylint" },
            rust = { "clippy" },
            go = { "golangci_lint" },
            c = { "cppcheck" },
            cpp = { "cppcheck" },
            java = { "checkstyle" },
            lua = { "luacheck" },
            bash = { "shellcheck" },
        }

        -- Define a custom linter for checkstyle
        lint.linters.checkstyle = {
            cmd = "checkstyle",
            args = function()
                -- Dynamically locate the checkstyle.xml file in the project root
                local root_dir = require("lint.utils").find_root({ ".git", "pom.xml", "build.gradle" })
                if not root_dir then
                    vim.notify("Could not find project root for checkstyle.", vim.log.levels.WARN)
                    return {}
                end

                -- Construct the path to checkstyle.xml
                local config_path = root_dir .. "/checkstyle.xml"
                if not vim.fn.filereadable(config_path) then
                    vim.notify("checkstyle.xml not found at " .. config_path, vim.log.levels.WARN)
                    return {}
                end

                return {
                    "-c",
                    config_path, -- Specify the configuration file
                    "--format",
                    "plain", -- Output format
                    "-", -- Read from stdin
                }
            end,
            stdin = true,
        }

        local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

        vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
            group = lint_augroup,
            callback = function()
                lint.try_lint()
            end,
        })

        vim.keymap.set("n", "<leader>l", function()
            lint.try_lint()
        end, { desc = "Trigger linting for current file" })
    end,
}
