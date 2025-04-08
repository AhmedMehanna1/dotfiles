-- lua/plugins/lsp/rust.lua

local lspconfig = require("lspconfig")
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local capabilities = cmp_nvim_lsp.default_capabilities()

lspconfig.rust_analyzer.setup({
    capabilities = capabilities,
    settings = {
        ["rust-analyzer"] = {
            diagnostics = {
                enable = true, -- Enable diagnostics
            },
            cargo = {
                allFeatures = true, -- Enable all features
            },
            checkOnSave = {
                command = "clippy", -- Run `cargo clippy` on save
            },
        },
    },
})
