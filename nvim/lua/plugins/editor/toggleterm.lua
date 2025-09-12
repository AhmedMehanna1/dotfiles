return {
    'akinsho/toggleterm.nvim',
    version = "*",
    keys = {
        { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>",            desc = "Terminal (float)" },
        { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>",       desc = "Terminal (horizontal)" },
        { "<leader>tv", "<cmd>ToggleTerm direction=vertical size=80<cr>", desc = "Terminal (vertical)" },
        { "<C-/>",      "<cmd>ToggleTerm<cr>",                            desc = "Terminal" },
        { "<C-_>",      "<cmd>ToggleTerm<cr>",                            desc = "which_key_ignore" },
    },
    opts = {
        size = function(term)
            if term.direction == "horizontal" then
                return 15
            elseif term.direction == "vertical" then
                return vim.o.columns * 0.3
            end
        end,
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_terminals = false,
        insert_mappings = true,
        terminal_mappings = true,
        persist_size = true,
        persist_mode = true,
        direction = 'float',
        close_on_exit = true,
        shell = vim.o.shell,
        auto_scroll = true,
        float_opts = {
            border = 'curved',
            width = function()
                return math.floor(vim.o.columns * 0.8)
            end,
            height = function()
                return math.floor(vim.o.lines * 0.8)
            end,
        },
    },
}
