return {
    {
        "folke/tokyonight.nvim",
        lazy = true,
        opts = { style = "moon" },
    },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            require("catppuccin").setup({
                transparent_background = true, -- disables setting the background color.
                float = {
                    transparent = true, -- enable transparent floating windows
                    solid = true, -- use solid styling for floating windows, see |winborder|
                },
            })
            vim.cmd.colorscheme("catppuccin")
        end,
    },
}
