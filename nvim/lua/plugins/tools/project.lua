return {
    "coffebar/neovim-project",
    opts = {
        projects = {
            "~/projects/*",
            "~/work/*",
            "~/.config/*",
        },
        picker = {
            type = "telescope",
        },
    },
    dependencies = {
        { "nvim-lua/plenary.nvim" },
        { "nvim-telescope/telescope.nvim" },
        { "Shatur/neovim-session-manager" },
    },
    keys = {
        { "<leader>fp", "<cmd>Telescope neovim-project discover<cr>", desc = "Projects" },
    },
    priority = 100,
}
