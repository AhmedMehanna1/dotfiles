return {
    "williamboman/mason.nvim", -- Mason for managing LSP servers and tools
    dependencies = {
        "williamboman/mason-lspconfig.nvim", -- Bridge between Mason and LSP-Config
        "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = { -- Ensure these servers are installed automatically
                "rust_analyzer",
                "gopls",
                "clangd",
                "jdtls",
                "pyright",
                "jsonls",
                "yamlls",
                "lemminx",
            },
            automatic_installation = true,
        })
        require("mason-tool-installer").setup({
            "stylua", -- lua formatter
            "lua-language-server",
            "typescript-language-server",
            "bash-language-server",
            "shellcheck",
            "docker-compose-language-service",
            "dockerfile-language-server",
        })

        -- Default setup for all LSPs
        local lspconfig = require("lspconfig")
        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        -- Default options for all LSPs
        local default_opts = {
            capabilities = capabilities,
        }

        -- Automatically set up all installed LSPs
        require("mason-lspconfig").setup_handlers({
            function(server_name)
                lspconfig[server_name].setup(default_opts)
            end,
        })
    end,
}
