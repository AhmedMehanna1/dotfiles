return {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    keys = {
        {
            "<leader>re",
            function() require('refactoring').refactor('Extract Function') end,
            mode = "x",
            desc = "Extract Function",
        },
        {
            "<leader>rf",
            function() require('refactoring').refactor('Extract Function To File') end,
            mode = "x",
            desc = "Extract Function To File",
        },
        {
            "<leader>rv",
            function() require('refactoring').refactor('Extract Variable') end,
            mode = "x",
            desc = "Extract Variable",
        },
        {
            "<leader>ri",
            function() require('refactoring').refactor('Inline Variable') end,
            mode = { "n", "x" },
            desc = "Inline Variable",
        },
        {
            "<leader>rb",
            function() require('refactoring').refactor('Extract Block') end,
            desc = "Extract Block",
        },
        {
            "<leader>rbf",
            function() require('refactoring').refactor('Extract Block To File') end,
            desc = "Extract Block To File",
        },
        {
            "<leader>rp",
            function() require('refactoring').debug.printf({ below = false }) end,
            desc = "Debug Print",
        },
        {
            "<leader>rv",
            function() require('refactoring').debug.print_var() end,
            mode = { "x", "n" },
            desc = "Debug Print Variable",
        },
        {
            "<leader>rc",
            function() require('refactoring').debug.cleanup({}) end,
            desc = "Debug Cleanup",
        },
    },
    opts = {
        prompt_func_return_type = {
            go = false,
            java = true,
            cpp = false,
            c = false,
            h = false,
            hpp = false,
            cxx = false,
        },
        prompt_func_param_type = {
            go = false,
            java = true,
            cpp = false,
            c = false,
            h = false,
            hpp = false,
            cxx = false,
        },
        printf_statements = {},
        print_var_statements = {},
        show_success_message = true,
    },
}
