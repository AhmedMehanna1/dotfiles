return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        { "antosha417/nvim-lsp-file-operations", config = true },
        { "folke/neodev.nvim", opts = {} },
    },
    config = function()
        -- import lspconfig plugin
        local lspconfig = require("lspconfig")

        local keymap = vim.keymap -- for conciseness

        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", {}),
            callback = function(ev)
                -- Buffer local mappings.
                -- See `:help vim.lsp.*` for documentation on any of the below functions
                local opts = { buffer = ev.buf, silent = true }

                -- -- Set vim motion for <Space> + c + h to show code documentation about the code the cursor is currently over if available
                -- vim.keymap.set("n", "<leader>ch", vim.lsp.buf.hover, { desc = "[C]ode [H]over Documentation" })
                -- -- Set vim motion for <Space> + c + d to go where the code/variable under the cursor was defined
                -- vim.keymap.set("n", "<leader>cd", vim.lsp.buf.definition, { desc = "[C]ode Goto [D]efinition" })
                -- -- Set vim motion for <Space> + c + a for display code action suggestions for code diagnostics in both normal and visual mode
                -- vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "[C]ode [A]ctions" })
                -- -- Set vim motion for <Space> + c + r to display references to the code under the cursor
                -- vim.keymap.set(
                --     "n",
                --     "<leader>cr",
                --     require("telescope.builtin").lsp_references,
                --     { desc = "[C]ode Goto [R]eferences" }
                -- )
                -- -- Set vim motion for <Space> + c + i to display implementations to the code under the cursor
                -- vim.keymap.set(
                --     "n",
                --     "<leader>ci",
                --     require("telescope.builtin").lsp_implementations,
                --     { desc = "[C]ode Goto [I]mplementations" }
                -- )
                -- -- Set a vim motion for <Space> + c + <Shift>R to smartly rename the code under the cursor
                -- vim.keymap.set("n", "<leader>cR", vim.lsp.buf.rename, { desc = "[C]ode [R]ename" })
                -- -- Set a vim motion for <Space> + c + <Shift>D to go to where the code/object was declared in the project (class file)
                -- vim.keymap.set("n", "<leader>cD", vim.lsp.buf.declaration, { desc = "[C]ode Goto [D]eclaration" })

                -- set keybinds
                opts.desc = "Show LSP references"
                keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

                opts.desc = "Go to declaration"
                keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

                opts.desc = "Show LSP definitions"
                keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

                opts.desc = "Show LSP implementations"
                keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

                opts.desc = "Show LSP type definitions"
                keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

                opts.desc = "See available code actions"
                keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

                opts.desc = "Smart rename"
                keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

                -- opts.desc = "Show buffer diagnostics"
                -- keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file
                --
                -- opts.desc = "Show line diagnostics"
                -- keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

                opts.desc = "Go to previous diagnostic"
                keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

                opts.desc = "Go to next diagnostic"
                keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

                opts.desc = "Show documentation for what is under cursor"
                keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

                opts.desc = "Restart LSP"
                keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
            end,
        })

        local default_diagnostic_config = {
            signs = {
                active = true,
                values = {
                    { name = "DiagnosticSignError", text = " " },
                    { name = "DiagnosticSignWarn", text = " " },
                    { name = "DiagnosticSignHint", text = "󰠠 " },
                    { name = "DiagnosticSignInfo", text = " " },
                },
            },
            virtual_text = false,
            update_in_insert = false,
            underline = true,
            severity_sort = true,
            float = {
                focusable = true,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        }
        vim.diagnostic.config(default_diagnostic_config)

        for _, sign in ipairs(vim.tbl_get(vim.diagnostic.config(), "signs", "values") or {}) do
            vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = sign.name })
        end

        -- -- Change the Diagnostic symbols in the sign column (gutter)
        -- -- (not in youtube nvim video)
        -- local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
        -- for type, icon in pairs(signs) do
        --     local hl = "DiagnosticSign" .. type
        --     vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        -- end

        require("plugins.lsp.config.rust") -- Load Rust LSP configuration
        require("plugins.lsp.config.go") -- Load Go LSP configuration
        require("plugins.lsp.config.c_cpp") -- Load C/C++ LSP configuration
        require("plugins.lsp.config.python") -- Load Python LSP configuration
        require("plugins.lsp.config.json") -- Load JSON, LSP configuration
        require("plugins.lsp.config.yaml") -- Load YAML LSP configuration
        require("plugins.lsp.config.xml") -- Load XML LSP configuration
        require("plugins.lsp.config.bash") -- Load BASH LSP configuration
    end,
}
