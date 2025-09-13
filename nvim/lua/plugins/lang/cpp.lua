return {
    -- C/C++ enhanced support
    {
        "p00f/clangd_extensions.nvim",
        ft = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
        opts = {
            inlay_hints = {
                inline = false,
                only_current_line = false,
                only_current_line_autocmd = "CursorHold",
                show_parameter_hints = true,
                parameter_hints_prefix = "<- ",
                other_hints_prefix = "=> ",
                max_len_align = false,
                max_len_align_padding = 1,
                right_align = false,
                right_align_padding = 7,
                highlight = "Comment",
                priority = 100,
            },
            ast = {
                role_icons = {
                    type = "",
                    declaration = "",
                    expression = "",
                    specifier = "",
                    statement = "",
                    ["template argument"] = "",
                },
                kind_icons = {
                    Compound = "",
                    Recovery = "",
                    TranslationUnit = "",
                    PackExpansion = "",
                    TemplateTypeParm = "",
                    TemplateTemplateParm = "",
                    TemplateParamObject = "",
                },
            },
        },
        config = function(_, opts)
            require("clangd_extensions").setup(opts)
        end,
        keys = {
            { "<leader>cA", "<cmd>ClangdAST<cr>", desc = "Clangd AST" },
            { "<leader>cH", "<cmd>ClangdTypeHierarchy<cr>", desc = "Type Hierarchy" },
            { "<leader>cS", "<cmd>ClangdSymbolInfo<cr>", desc = "Symbol Info" },
            { "<leader>cM", "<cmd>ClangdMemoryUsage<cr>", desc = "Memory Usage" },
        },
    },
    -- CMake support
    {
        "cdelledonne/vim-cmake",
        ft = { "c", "cpp", "cmake" },
        keys = {
            { "<leader>mg", "<cmd>CMakeGenerate<cr>", desc = "Generate" },
            { "<leader>mb", "<cmd>CMakeBuild<cr>", desc = "Build" },
            { "<leader>mq", "<cmd>CMakeQuickBuild<cr>", desc = "Quick Build" },
            { "<leader>mi", "<cmd>CMakeInstall<cr>", desc = "Install" },
            { "<leader>mc", "<cmd>CMakeClean<cr>", desc = "Clean" },
            { "<leader>mt", "<cmd>CMakeTest<cr>", desc = "Test" },
            { "<leader>mo", "<cmd>CMakeOpen<cr>", desc = "Open CMake Console" },
            { "<leader>mr", "<cmd>CMakeClose<cr>", desc = "Close CMake Console" },
        },
    },
}