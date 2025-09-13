return {
    "stevearc/conform.nvim",
    dependencies = { "mason.nvim" },
    lazy = true,
    cmd = "ConformInfo",
    keys = {
        {
            "<leader>cf",
            function()
                require("conform").format({ timeout_ms = 3000, lsp_fallback = true })
            end,
            mode = { "n", "v" },
            desc = "Format Document",
        },
    },
    init = function()
        vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
    opts = {
        formatters_by_ft = {
            lua = { "stylua" },
            python = { "isort", "black" },
            rust = { "rustfmt" },
            java = { "clang-format" }, -- ✅ use clang-format
            javascript = { { "prettierd", "prettier" } },
            typescript = { { "prettierd", "prettier" } },
            typescriptreact = { { "prettierd", "prettier" } },
            javascriptreact = { { "prettierd", "prettier" } },
            json = { { "prettierd", "prettier" } },
            go = { "gofumpt", "goimports" },
            c = { "clang-format" },
            cpp = { "clang-format" },
            cs = { "csharpier" },
            kotlin = { "ktlint" },
            html = { { "prettierd", "prettier" } },
            css = { { "prettierd", "prettier" } },
            scss = { { "prettierd", "prettier" } },
            less = { { "prettierd", "prettier" } },
            dockerfile = { { "prettierd", "prettier" } },
            yaml = { { "prettierd", "prettier" } },
            yml = { { "prettierd", "prettier" } },
        },
        formatters = {
            injected = { options = { ignore_errors = true } },
            ["clang-format"] = {
                prepend_args = { "-style=file" }, -- look for .clang-format
            },
        },
    },
}
