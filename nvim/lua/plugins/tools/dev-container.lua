return {
    'esensar/nvim-dev-container',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    keys = {
        { "<leader>cdu", function() require("devcontainer").up() end,    desc = "Dev Container Up" },
        { "<leader>cdd", function() require("devcontainer").down() end,  desc = "Dev Container Down" },
        { "<leader>cds", function() require("devcontainer").shell() end, desc = "Dev Container Shell" },
        { "<leader>cdr", function() require("devcontainer").exec() end,  desc = "Dev Container Exec" },
    },
    config = function()
        require("devcontainer").setup({
            workspace_folder_provider = function()
                return vim.loop.cwd()
            end
        })
    end,
}
