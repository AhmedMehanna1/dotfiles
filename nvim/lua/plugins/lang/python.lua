return {
    {
        "linux-cultist/venv-selector.nvim",
        dependencies = {
            "neovim/nvim-lspconfig",
            "mfussenegger/nvim-dap",
            "mfussenegger/nvim-dap-python",
            { "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } },
        },
        cmd = "VenvSelect",
        ft = "python",
        keys = {
            { "<leader>vs", "<cmd>VenvSelect<cr>", desc = "Select Python Virtual Environment" },
            { "<leader>vc", "<cmd>VenvSelectCached<cr>", desc = "Select Cached Python Virtual Environment" },
        },
        config = function()
            local ok, venv_selector = pcall(require, "venv-selector")
            if ok then
                venv_selector.setup({
                    settings = {
                        options = {
                            notify_user_on_venv_activation = true,
                            enable_default_searches = true,
                            enable_cached_venvs = true,
                        },
                    },
                })
            else
                vim.notify("venv-selector failed to load", vim.log.levels.WARN)
            end
        end,
    },
    {
        "mfussenegger/nvim-dap-python",
        dependencies = "mfussenegger/nvim-dap",
        ft = "python",
        config = function()
            local dap_python = require("dap-python")
            -- Try different Python executables
            local python_path = vim.fn.exepath("python3") ~= "" and "python3" or "python"
            dap_python.setup(python_path)
        end,
    },
}
