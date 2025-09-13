return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
    },
    keys = {
        {
            "<leader>fe",
            function()
                local ok, nt = pcall(require, "neo-tree.command")
                if ok then
                    nt.execute({ toggle = true, dir = vim.loop.cwd() })
                else
                    vim.notify("Neo-tree not loaded", vim.log.levels.WARN)
                end
            end,
            desc = "Explorer NeoTree (cwd)",
        },
        {
            "<leader>fE",
            function()
                local ok, nt = pcall(require, "neo-tree.command")
                if ok then
                    nt.execute({ toggle = true, dir = require("utils").root() })
                else
                    vim.notify("Neo-tree not loaded", vim.log.levels.WARN)
                end
            end,
            desc = "Explorer NeoTree (root dir)",
        },
        { "<leader>e", "<leader>fe", desc = "Explorer NeoTree (cwd)", remap = true },
        { "<leader>E", "<leader>fE", desc = "Explorer NeoTree (root dir)", remap = true },
        {
            "<leader>ge",
            function()
                local ok, nt = pcall(require, "neo-tree.command")
                if ok then
                    nt.execute({ source = "git_status", toggle = true })
                else
                    vim.notify("Neo-tree not loaded", vim.log.levels.WARN)
                end
            end,
            desc = "Git explorer",
        },
        {
            "<leader>be",
            function()
                local ok, nt = pcall(require, "neo-tree.command")
                if ok then
                    nt.execute({ source = "buffers", toggle = true })
                else
                    vim.notify("Neo-tree not loaded", vim.log.levels.WARN)
                end
            end,
            desc = "Buffer explorer",
        },
    },
    deactivate = function()
        vim.cmd([[Neotree close]])
    end,
    init = function()
        if vim.fn.argc(-1) == 1 then
            local stat = vim.loop.fs_stat(vim.fn.argv(0))
            if stat and stat.type == "directory" then
                -- delay loading so lazy.nvim finishes first
                vim.schedule(function()
                    require("neo-tree")
                end)
            end
        end
    end,
    opts = {
        sources = { "filesystem", "buffers", "git_status", "document_symbols" },
        open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
        filesystem = {
            bind_to_cwd = false,
            follow_current_file = { enabled = true },
            use_libuv_file_watcher = true,
            filtered_items = {
                visible = true, -- Show hidden files by default
                show_hidden_count = true,
                hide_dotfiles = false,
                hide_gitignored = false,
                hide_by_name = {},
                hide_by_pattern = {},
                always_show = { ".env", ".gitignore" },
                never_show = {},
            },
        },
        window = {
            mappings = {
                ["<space>"] = "none",
                ["Y"] = function(state)
                    local node = state.tree:get_node()
                    local path = node:get_id()
                    vim.fn.setreg("+", path, "c")
                    vim.notify("Copied path: " .. path, vim.log.levels.INFO)
                end,
            },
        },
        default_component_configs = {
            indent = {
                with_expanders = true,
                expander_collapsed = "",
                expander_expanded = "",
                expander_highlight = "NeoTreeExpander",
            },
        },
    },
    config = function(_, opts)
        require("neo-tree").setup(opts)

        -- Refresh git status after closing lazygit terminal
        vim.api.nvim_create_autocmd("TermClose", {
            pattern = "*lazygit",
            callback = function()
                if package.loaded["neo-tree.sources.git_status"] then
                    require("neo-tree.sources.git_status").refresh()
                end
            end,
        })
    end,
}
