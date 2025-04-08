local lspconfig = require("lspconfig")
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local capabilities = cmp_nvim_lsp.default_capabilities()

lspconfig.bashls.setup({
    capabilities = capabilities,
    cmd = { "bash-language-server", "start" }, -- Command to start the server
    filetypes = { "sh", "bash" }, -- Filetypes to attach to
    root_dir = lspconfig.util.root_pattern(".git", ".bashrc", ".bash_profile"), -- Root directory detection
    settings = {
        bashIde = {
            globPattern = "*.sh", -- Pattern for Bash files
        },
    },
})
