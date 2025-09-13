return {
    -- Docker support
    {
        "ekalinin/Dockerfile.vim",
        ft = "dockerfile",
        config = function()
            -- Enhanced Dockerfile support
            vim.g.dockerfile_fold = 1
        end,
    },
    -- Docker Compose detection and basic support
    {
        "towolf/vim-helm",
        ft = { "yaml", "helm" },
    },
}