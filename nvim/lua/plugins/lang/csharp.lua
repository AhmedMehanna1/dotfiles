return {
    -- C# development support
    {
        "OmniSharp/omnisharp-vim",
        ft = "cs",
        init = function()
            vim.g.OmniSharp_highlighting = 3
            vim.g.OmniSharp_popup_position = "peek"
            vim.g.OmniSharp_popup_options = {
                highlight = "Normal",
                padding = { 0, 0, 0, 0 },
                border = "rounded",
            }
            vim.g.OmniSharp_selector_ui = "fzf"
            vim.g.OmniSharp_start_without_solution = 1
        end,
        keys = {
            { "<leader>ca", "<cmd>OmniSharpCodeActions<cr>", desc = "Code Actions (C#)" },
            { "<leader>cd", "<cmd>OmniSharpGotoDefinition<cr>", desc = "Go to Definition (C#)" },
            { "<leader>ci", "<cmd>OmniSharpFindImplementations<cr>", desc = "Find Implementations (C#)" },
            { "<leader>ct", "<cmd>OmniSharpFindType<cr>", desc = "Find Type (C#)" },
            { "<leader>cs", "<cmd>OmniSharpFindSymbol<cr>", desc = "Find Symbol (C#)" },
            { "<leader>cu", "<cmd>OmniSharpFindUsages<cr>", desc = "Find Usages (C#)" },
            { "<leader>cr", "<cmd>OmniSharpRename<cr>", desc = "Rename (C#)" },
            { "<leader>cf", "<cmd>OmniSharpCodeFormat<cr>", desc = "Format Code (C#)" },
            { "<leader>cb", "<cmd>OmniSharpBuild<cr>", desc = "Build (C#)" },
            { "<leader>cB", "<cmd>OmniSharpBuildAsync<cr>", desc = "Build Async (C#)" },
            { "<leader>cR", "<cmd>OmniSharpRestartServer<cr>", desc = "Restart Server (C#)" },
        },
    },
    -- Razor support
    {
        "jlcrochet/vim-razor",
        ft = { "razor", "cshtml" },
    },
}