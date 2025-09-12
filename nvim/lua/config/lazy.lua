require("lazy").setup({
    spec = {
        -- Import all plugin categories
        { import = "plugins.ui" },
        { import = "plugins.editor" },
        { import = "plugins.coding" },
        { import = "plugins.lsp" },
        { import = "plugins.debug" },
        { import = "plugins.test" },
        { import = "plugins.tools" },
        { import = "plugins.lang" },
    },
    defaults = {
        lazy = false,
        version = false,
    },
    install = { colorscheme = { "tokyonight", "habamax" } },
    checker = {
        enabled = true,
        notify = false,
    },
    performance = {
        cache = {
            enabled = true,
        },
        rtp = {
            disabled_plugins = {
                "gzip",
                "matchit",
                "matchparen",
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
})
