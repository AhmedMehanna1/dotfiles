return {
    "kndndrj/nvim-dbee",
    dependencies = {
        "MunifTanjim/nui.nvim",
    },
    build = function()
        require("dbee").install()
    end,
    keys = {
        { "<leader>db", function() require("dbee").toggle() end, desc = "Toggle Database" },
    },
    config = function()
        require("dbee").setup({
            sources = {
                require("dbee.sources").MemorySource:new({
                    ---@diagnostic disable-next-line: missing-fields
                    {
                        name = "local_sqlite",
                        type = "sqlite",
                        url = vim.fn.stdpath("data") .. "/databases/local.db",
                    },
                }),
                require("dbee.sources").EnvSource:new("DBEE_CONNECTIONS"),
                require("dbee.sources").FileSource:new(vim.fn.stdpath("config") .. "/dbee/connections.json"),
            },
        })
    end,
}
