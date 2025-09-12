return {
    {
        "ray-x/go.nvim",
        dependencies = {
            "ray-x/guihua.lua",
            "neovim/nvim-lspconfig",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require("go").setup()
        end,
        event = { "CmdlineEnter" },
        ft = { "go", 'gomod' },
        build = ':lua require("go.install").update_all_sync()',
        keys = {
            { "<leader>gsj", "<cmd>GoAddTag json<cr>", desc = "Add JSON struct tags" },
            { "<leader>gsy", "<cmd>GoAddTag yaml<cr>", desc = "Add YAML struct tags" },
            { "<leader>grt", "<cmd>GoRmTag<cr>",       desc = "Remove struct tags" },
            { "<leader>gfs", "<cmd>GoFillStruct<cr>",  desc = "Fill struct" },
            { "<leader>gie", "<cmd>GoIfErr<cr>",       desc = "Add if err" },
            { "<leader>gch", "<cmd>GoCoverage<cr>",    desc = "Test coverage" },
            { "<leader>gta", "<cmd>GoTest<cr>",        desc = "Run tests" },
            { "<leader>gtA", "<cmd>GoTestAdd<cr>",     desc = "Add test" },
            { "<leader>gtf", "<cmd>GoTestFunc<cr>",    desc = "Test function" },
            { "<leader>gtF", "<cmd>GoTestFile<cr>",    desc = "Test file" },
        },
    },
}
