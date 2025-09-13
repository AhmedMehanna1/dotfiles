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
        -- Keymaps moved to ftplugin/cs.lua so they are buffer-local
    },
    -- Razor support
    {
        "jlcrochet/vim-razor",
        ft = { "razor", "cshtml" },
    },
}
