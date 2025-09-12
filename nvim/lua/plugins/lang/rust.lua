return {
    -- Rust crate management
    {
        "saecki/crates.nvim", -- ✅ Fixed URL
        event = { "BufRead Cargo.toml" },
        opts = {
            popup = {
                autofocus = true,
            },
        },
        config = function(_, opts)
            require("crates").setup(opts)
            require("cmp").setup.buffer({
                sources = { { name = "crates" } },
            })
        end,
    },
    -- Additional Rust tools
    {
        "rust-lang/rust.vim",
        ft = "rust",
        init = function()
            vim.g.rustfmt_autosave = 1
        end,
    },
}
