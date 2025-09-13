return {
    -- TypeScript/JavaScript React support
    {
        "jose-elias-alvarez/typescript.nvim",
        ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
        opts = {
            server = {
                settings = {
                    typescript = {
                        inlayHints = {
                            includeInlayParameterNameHints = "all",
                            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                            includeInlayFunctionParameterTypeHints = true,
                            includeInlayVariableTypeHints = false,
                            includeInlayPropertyDeclarationTypeHints = true,
                            includeInlayFunctionLikeReturnTypeHints = true,
                            includeInlayEnumMemberValueHints = true,
                        },
                    },
                    javascript = {
                        inlayHints = {
                            includeInlayParameterNameHints = "all",
                            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                            includeInlayFunctionParameterTypeHints = true,
                            includeInlayVariableTypeHints = false,
                            includeInlayPropertyDeclarationTypeHints = true,
                            includeInlayFunctionLikeReturnTypeHints = true,
                            includeInlayEnumMemberValueHints = true,
                        },
                    },
                },
            },
        },
    },
    -- React/JSX support
    {
        "windwp/nvim-ts-autotag",
        ft = {
            "html",
            "javascript",
            "typescript",
            "javascriptreact",
            "typescriptreact",
            "svelte",
            "vue",
            "tsx",
            "jsx",
            "rescript",
            "xml",
            "php",
            "markdown",
            "astro",
            "glimmer",
            "handlebars",
            "hbs",
        },
        config = function()
            require("nvim-ts-autotag").setup()
        end,
    },
    -- Tailwind CSS support
    {
        "roobert/tailwindcss-colorizer-cmp.nvim",
        config = function()
            require("tailwindcss-colorizer-cmp").setup({
                color_square_width = 2,
            })
        end,
    },
    -- Package.json support
    {
        "vuki656/package-info.nvim",
        ft = "json",
        config = function()
            require("package-info").setup()
        end,
        keys = {
            {
                "<leader>ns",
                function()
                    require("package-info").show()
                end,
                desc = "Show package info",
            },
            {
                "<leader>nc",
                function()
                    require("package-info").hide()
                end,
                desc = "Hide package info",
            },
            {
                "<leader>nt",
                function()
                    require("package-info").toggle()
                end,
                desc = "Toggle package info",
            },
            {
                "<leader>nu",
                function()
                    require("package-info").update()
                end,
                desc = "Update package",
            },
            {
                "<leader>nd",
                function()
                    require("package-info").delete()
                end,
                desc = "Delete package",
            },
            {
                "<leader>ni",
                function()
                    require("package-info").install()
                end,
                desc = "Install package",
            },
            {
                "<leader>np",
                function()
                    require("package-info").change_version()
                end,
                desc = "Change package version",
            },
        },
    },
}