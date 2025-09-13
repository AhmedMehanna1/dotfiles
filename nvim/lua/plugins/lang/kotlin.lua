return {
    -- Kotlin language support
    {
        "udalov/kotlin-vim",
        ft = "kotlin",
    },
    -- Android development support
    {
        "hsanson/vim-android",
        ft = { "kotlin", "java" },
        config = function()
            vim.g.android_sdk_path = vim.fn.expand("~/Android/Sdk")
            vim.g.gradle_path = vim.fn.expand("~/.gradle")
        end,
        keys = {
            { "<leader>aa", "<cmd>Android<cr>", desc = "Android Menu" },
            { "<leader>ab", "<cmd>AndroidBuild<cr>", desc = "Android Build" },
            { "<leader>ai", "<cmd>AndroidInstall<cr>", desc = "Android Install" },
            { "<leader>ar", "<cmd>AndroidRun<cr>", desc = "Android Run" },
            { "<leader>at", "<cmd>AndroidTest<cr>", desc = "Android Test" },
            { "<leader>ac", "<cmd>AndroidClean<cr>", desc = "Android Clean" },
        },
    },
}