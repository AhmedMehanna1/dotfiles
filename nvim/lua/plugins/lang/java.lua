return {
    -- Java Spring Boot support
    {
        "elmcgill/springboot-nvim",
        dependencies = {
            "neovim/nvim-lspconfig",
            "mfussenegger/nvim-jdtls",
        },
        keys = {
            { "<leader>Jr", function() require("springboot-nvim").boot_run() end,       desc = "Spring Boot Run" },
            { "<leader>Js", function() require("springboot-nvim").boot_stop() end,      desc = "Spring Boot Stop" },
            { "<leader>Jc", function() require("springboot-nvim").generate_class() end, desc = "Generate Class" },
        },
        ft = "java",
        config = function()
            local springboot_nvim = require("springboot-nvim")
            springboot_nvim.setup()
        end,
    },
}
