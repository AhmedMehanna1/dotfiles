return {
    -- Rust crate management
    {
        "saecki/crates.nvim",
        event = { "BufRead Cargo.toml" },
        opts = {
            popup = {
                autofocus = true,
                hide_on_select = true,
                copy_register = "+",
            },
            completion = {
                cmp = {
                    enabled = true,
                },
            },
            lsp = {
                enabled = true,
                on_attach = function(client, bufnr)
                    -- Additional crates.nvim specific LSP config
                end,
                actions = true,
                completion = true,
                hover = true,
            },
        },
        config = function(_, opts)
            require("crates").setup(opts)
            require("cmp").setup.buffer({
                sources = { { name = "crates" } },
            })
        end,
        keys = {
            { "<leader>rct", function() require("crates").toggle() end, desc = "Toggle crates" },
            { "<leader>rcr", function() require("crates").reload() end, desc = "Reload crates" },
            { "<leader>rcv", function() require("crates").show_versions_popup() end, desc = "Show versions" },
            { "<leader>rcf", function() require("crates").show_features_popup() end, desc = "Show features" },
            { "<leader>rcd", function() require("crates").show_dependencies_popup() end, desc = "Show dependencies" },
            { "<leader>rcu", function() require("crates").update_crate() end, desc = "Update crate" },
            { "<leader>rca", function() require("crates").update_all_crates() end, desc = "Update all crates" },
            { "<leader>rcU", function() require("crates").upgrade_crate() end, desc = "Upgrade crate" },
            { "<leader>rcA", function() require("crates").upgrade_all_crates() end, desc = "Upgrade all crates" },
        },
    },
    -- Enhanced Rust tools
    {
        "rust-lang/rust.vim",
        ft = "rust",
        init = function()
            vim.g.rustfmt_autosave = 1
            vim.g.rustfmt_emit_files = 1
            vim.g.rustfmt_fail_silently = 0
            vim.g.rust_clip_command = "xclip -selection clipboard"
        end,
    },
    -- Rust debugging and testing
    {
        "simrat39/rust-tools.nvim",
        ft = "rust",
        opts = {
            tools = {
                runnables = {
                    use_telescope = true,
                },
                inlay_hints = {
                    auto = true,
                    show_parameter_hints = false,
                    parameter_hints_prefix = "",
                    other_hints_prefix = "",
                },
            },
            server = {
                on_attach = function(client, bufnr)
                    vim.keymap.set("n", "<C-space>", require("rust-tools").hover_actions.hover_actions, { buffer = bufnr })
                    vim.keymap.set("n", "<Leader>a", require("rust-tools").code_action_group.code_action_group, { buffer = bufnr })
                end,
            },
        },
        config = function(_, opts)
            require("rust-tools").setup(opts)
        end,
        keys = {
            { "<leader>rr", function() require("rust-tools").runnables.runnables() end, desc = "Rust Runnables" },
            { "<leader>rt", function() require("rust-tools").debuggables.debuggables() end, desc = "Rust Debuggables" },
            { "<leader>rm", function() require("rust-tools").expand_macro.expand_macro() end, desc = "Expand Macro" },
            { "<leader>rc", function() require("rust-tools").open_cargo_toml.open_cargo_toml() end, desc = "Open Cargo.toml" },
            { "<leader>rp", function() require("rust-tools").parent_module.parent_module() end, desc = "Parent Module" },
            { "<leader>rj", function() require("rust-tools").join_lines.join_lines() end, desc = "Join Lines" },
            { "<leader>rh", function() require("rust-tools").hover_actions.hover_actions() end, desc = "Hover Actions" },
        },
    },
}
