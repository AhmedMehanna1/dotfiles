return {
    {
        "folke/which-key.nvim",
        optional = true,
        keys = {
            -- Find Class (IdeaVim: GotoClass)
            {
                "<leader>fc",
                function()
                    require("telescope.builtin").lsp_dynamic_workspace_symbols({
                        symbols = { "Class", "Interface", "Enum", "Record" },
                        prompt_title = "Find Class",
                    })
                end,
                desc = "GotoClass – Lists class/struct symbols, falls back to Treesitter",
            },

            -- File structure / outline
            { "<leader>ss", "<cmd>AerialToggle<cr>", desc = "File Structure (Aerial)" },

            -- Close all buffers except current (IdeaVim: CloseAllEditorsButActive)
            {
                "<leader>xo",
                function()
                    if _G.Snacks and Snacks.bufdelete and Snacks.bufdelete.other then
                        Snacks.bufdelete.other()
                        return
                    end
                    -- fallback: wipe other listed buffers
                    local cur = vim.api.nvim_get_current_buf()
                    for _, b in ipairs(vim.api.nvim_list_bufs()) do
                        if b ~= cur and vim.bo[b].buflisted then
                            pcall(vim.api.nvim_buf_delete, b, { force = false })
                        end
                    end
                end,
                desc = "Close Other Buffers",
            },

            -- Debugging (IdeaVim-style)
            {
                "<leader>tb",
                function()
                    require("dap").toggle_breakpoint()
                end,
                desc = "Toggle Breakpoint",
                mode = { "n", "v" },
            },
            {
                "<leader>ds",
                function()
                    require("dap").continue()
                end,
                desc = "Debug/Continue",
            },
            {
                "<leader>dr",
                function()
                    require("dap").continue()
                end,
                desc = "Resume",
            },
            {
                "<leader>dn",
                function()
                    require("dap").step_over()
                end,
                desc = "Step Over",
            },
            {
                "<leader>di",
                function()
                    require("dap").step_into()
                end,
                desc = "Step Into",
            },
            {
                "<leader>do",
                function()
                    require("dap").step_out()
                end,
                desc = "Step Out",
            },
            {
                "<leader>dt",
                function()
                    require("dap").run_to_cursor()
                end,
                desc = "Run to Cursor",
            },
            {
                "<leader>dx",
                function()
                    require("dap").terminate()
                end,
                desc = "Stop Debug",
            },
            {
                "<leader>de",
                function()
                    require("dapui").eval()
                end,
                desc = "Evaluate",
                mode = { "n", "v" },
            },

            -- DAP UI helpers
            {
                "<leader>du",
                function()
                    require("dapui").toggle({})
                end,
                desc = "Debug UI",
            },
            {
                "<leader>dR",
                function()
                    require("dap").repl.toggle()
                end,
                desc = "Debug REPL",
            },
        },
    },
}
