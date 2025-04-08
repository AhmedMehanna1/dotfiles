return {
    "mfussenegger/nvim-jdtls", -- Plugin for Java development with jdtls
    dependencies = {
        "williamboman/mason.nvim",
        "neovim/nvim-lspconfig",
    },
    config = function()
        require("plugins.lsp.config.jdtls")
    end,
}
