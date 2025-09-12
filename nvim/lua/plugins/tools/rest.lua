return {
    "mistweaverco/kulala.nvim",
    ft = "http",
    keys = {
        {
            "<leader>rr",
            function()
                require("kulala").run()
            end,
            desc = "Run HTTP request",
        },
        {
            "<leader>ra",
            function()
                require("kulala").run_all()
            end,
            desc = "Run all HTTP requests",
        },
        {
            "<leader>rl",
            function()
                require("kulala").replay()
            end,
            desc = "Replay last HTTP request",
        },
        {
            "<leader>rt",
            function()
                require("kulala").toggle_view()
            end,
            desc = "Toggle HTTP result view",
        },
        {
            "<leader>rc",
            function()
                require("kulala").copy()
            end,
            desc = "Copy HTTP request",
        },
        {
            "<leader>ri",
            function()
                require("kulala").inspect()
            end,
            desc = "Inspect HTTP request",
        },
        {
            "<leader>re",
            function()
                require("kulala").set_selected_env()
            end,
            desc = "Set environment",
        },
    },
    opts = {
        -- default_view, body, headers
        default_view = "body",
        -- dev, test, prod, can be anything
        -- see: https://learn.microsoft.com/en-us/aspnet/core/test/http-files?view=aspnetcore-8.0#environment-files
        default_env = "dev",
        -- enable/disable debug mode
        debug = false,
        -- default formatters/parsers for different content types
        formatters = {
            json = { "jq", "." },
            xml = { "xmllint", "--format", "-" },
            html = { "tidy", "-i", "-q", "-" },
        },
        -- default icons
        icons = {
            inlay = {
                loading = "⏳",
                done = "✅",
                error = "❌",
            },
            lualine = "🐼",
        },
        -- additional cURL options
        -- see: https://curl.se/docs/manpage.html
        additional_curl_options = {},
    },
}
