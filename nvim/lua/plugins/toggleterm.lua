return {
    "akinsho/toggleterm.nvim",
    config = function()
        require("toggleterm").setup({
            size = 10, -- Height of the terminal
            open_mapping = "<C-Enter>", -- Keybinding to toggle the terminal
            direction = "horizontal", -- Options: 'horizontal', 'vertical', 'float'
            shade_terminals = true, -- Add a slight background shade
        })
    end,
}
