return {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
        "nvim-lua/plenary.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
            enabled = vim.fn.executable("make") == 1,
            config = function()
                require("telescope").load_extension("fzf")
            end,
        },
        {
            "nvim-telescope/telescope-smart-history.nvim",
            dependencies = { "kkharji/sqlite.lua" },
            config = function()
                require("telescope").load_extension("smart_history")
            end,
        },
    },
    keys = {
        {
            "<leader>,",
            "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",
            desc = "Switch Buffer",
        },
        {
            "<leader>/",
            function() telescope_live_grep_with_history() end,
            desc = "Grep (root dir)",
        },
        {
            "<leader>:",
            "<cmd>Telescope command_history<cr>",
            desc = "Command History",
        },
        {
            "<leader><space>",
            function() telescope_find_files_with_history() end,
            desc = "Find Files (root dir)",
        },
        -- find
        {
            "<leader>fb",
            "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",
            desc = "Buffers",
        },
        {
            "<leader>fc",
            function()
                require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config"), hidden = true, no_ignore = true })
            end,
            desc = "Find Config File",
        },
        {
            "<leader>ff",
            function() telescope_find_files_with_history() end,
            desc = "Find Files (root dir)",
        },
        {
            "<leader>fF",
            function()
                require("telescope.builtin").find_files({ cwd = false, hidden = true, no_ignore = true })
            end,
            desc = "Find Files (cwd)",
        },
        {
            "<leader>fr",
            function() telescope_oldfiles_with_history() end,
            desc = "Recent",
        },
        {
            "<leader>fR",
            function()
                require("telescope.builtin").oldfiles({ cwd = vim.loop.cwd() })
            end,
            desc = "Recent (cwd)",
        },
        -- git
        {
            "<leader>gc",
            "<cmd>Telescope git_commits<CR>",
            desc = "commits",
        },
        {
            "<leader>gs",
            "<cmd>Telescope git_status<CR>",
            desc = "status",
        },
        -- search
        {
            '<leader>s"',
            "<cmd>Telescope registers<cr>",
            desc = "Registers",
        },
        {
            "<leader>sa",
            "<cmd>Telescope autocommands<cr>",
            desc = "Auto Commands",
        },
        {
            "<leader>sb",
            "<cmd>Telescope current_buffer_fuzzy_find<cr>",
            desc = "Buffer",
        },
        {
            "<leader>sc",
            "<cmd>Telescope command_history<cr>",
            desc = "Command History",
        },
        {
            "<leader>sC",
            "<cmd>Telescope commands<cr>",
            desc = "Commands",
        },
        {
            "<leader>sd",
            "<cmd>Telescope diagnostics bufnr=0<cr>",
            desc = "Document diagnostics",
        },
        {
            "<leader>sD",
            "<cmd>Telescope diagnostics<cr>",
            desc = "Workspace diagnostics",
        },
        {
            "<leader>sg",
            function() telescope_live_grep_with_history() end,
            desc = "Grep (root dir)",
        },
        {
            "<leader>sG",
            function()
                require("telescope.builtin").live_grep({ cwd = false })
            end,
            desc = "Grep (cwd)",
        },
        {
            "<leader>sh",
            "<cmd>Telescope help_tags<cr>",
            desc = "Help Pages",
        },
        {
            "<leader>sH",
            "<cmd>Telescope highlights<cr>",
            desc = "Search Highlight Groups",
        },
        {
            "<leader>sk",
            "<cmd>Telescope keymaps<cr>",
            desc = "Key Maps",
        },
        {
            "<leader>sM",
            "<cmd>Telescope man_pages<cr>",
            desc = "Man Pages",
        },
        {
            "<leader>sm",
            "<cmd>Telescope marks<cr>",
            desc = "Jump to Mark",
        },
        {
            "<leader>so",
            "<cmd>Telescope vim_options<cr>",
            desc = "Options",
        },
        {
            "<leader>sR",
            "<cmd>Telescope resume<cr>",
            desc = "Resume",
        },
        {
            "<leader>sw",
            function()
                require("telescope.builtin").grep_string({ word_match = "-w" })
            end,
            desc = "Word (root dir)",
        },
        {
            "<leader>sW",
            function()
                require("telescope.builtin").grep_string({ cwd = false, word_match = "-w" })
            end,
            desc = "Word (cwd)",
        },
        {
            "<leader>sw",
            function()
                require("telescope.builtin").grep_string()
            end,
            mode = "v",
            desc = "Selection (root dir)",
        },
        {
            "<leader>sW",
            function()
                require("telescope.builtin").grep_string({ cwd = false })
            end,
            mode = "v",
            desc = "Selection (cwd)",
        },
        {
            "<leader>uC",
            function()
                require("telescope.builtin").colorscheme({ enable_preview = true })
            end,
            desc = "Colorscheme with preview",
        },
    },
    opts = function()
        local actions = require("telescope.actions")

        local open_with_trouble = function(...)
            return require("trouble.providers.telescope").open_with_trouble(...)
        end
        local open_selected_with_trouble = function(...)
            return require("trouble.providers.telescope").open_selected_with_trouble(...)
        end

        -- Create global variable to store last searches
        _G.telescope_last_search = _G.telescope_last_search or {}

        return {
            defaults = {
                prompt_prefix = " ",
                selection_caret = "->",
                -- Path display configuration - use smart to show short paths
                path_display = { "smart" }, -- Smart path display with short paths
                dynamic_preview_title = true,
                results_title = "Files",
                -- Show hidden files by default
                hidden = true,
                no_ignore = true, -- Show files even if in .gitignore
                no_ignore_parent = true,
                -- Ensure find command includes hidden files and ignores .gitignore
                find_command = { "rg", "--files", "--hidden", "--no-ignore", "--glob", "!**/.git/*" },
                -- Prevent horizontal scrolling of results
                scroll_strategy = "cycle", -- Use cycle instead of limit
                selection_strategy = "reset", -- Reset selection position
                sorting_strategy = "ascending",
                -- Layout configuration - vertical layout with search on top
                layout_strategy = "vertical",
                layout_config = {
                    vertical = {
                        prompt_position = "top", -- Search input at the top
                        mirror = false, -- Preview at bottom
                        preview_height = 0.5, -- Preview takes half the space
                        results_height = 0.3, -- Results take 30% (limited to ~5 items)
                    },
                    horizontal = {
                        prompt_position = "top",
                        preview_width = 0.55,
                        results_width = 0.8,
                        mirror = false,
                    },
                    width = 0.90, -- Slightly wider
                    height = 0.85, -- Slightly taller
                    preview_cutoff = 10, -- Always show preview
                },
                -- Limit results to 5 items for cleaner display
                results_height = 5,
                -- File sorter and finder
                file_sorter = require("telescope.sorters").get_fuzzy_file,
                file_ignore_patterns = { "node_modules" },
                generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
                -- Border configuration
                borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
                -- Disable horizontal scrolling in results window
                wrap_results = true, -- Wrap long lines instead of scrolling
                use_less = false, -- Don't use less-style scrolling
                -- Enable search history
                history = {
                    path = vim.fn.stdpath("data") .. "/telescope_history.sqlite3",
                    limit = 100, -- Store last 100 searches for each picker
                },
                get_selection_window = function()
                    local wins = vim.api.nvim_list_wins()
                    table.insert(wins, 1, vim.api.nvim_get_current_win())
                    for _, win in ipairs(wins) do
                        local buf = vim.api.nvim_win_get_buf(win)
                        if vim.bo[buf].buftype == "" then
                            return win
                        end
                    end
                    return 0
                end,
                mappings = {
                    i = {
                        ["<c-t>"] = open_with_trouble,
                        ["<a-t>"] = open_selected_with_trouble,
                        ["<a-i>"] = function()
                            require("telescope.builtin").find_files({ no_ignore = true })
                        end,
                        ["<a-h>"] = function()
                            require("telescope.builtin").find_files({ hidden = true })
                        end,
                        ["<C-Down>"] = function(...) require("telescope").extensions.smart_history.smart_history(...) end,
                        ["<C-Up>"] = function(...) require("telescope").extensions.smart_history.smart_history(...) end,
                        ["<C-f>"] = actions.preview_scrolling_down,
                        ["<C-b>"] = actions.preview_scrolling_up,
                        -- Navigation - these should only move selection, not scroll horizontally
                        ["<Down>"] = actions.move_selection_next,
                        ["<Up>"] = actions.move_selection_previous,
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-k>"] = actions.move_selection_previous,
                        ["<C-n>"] = actions.move_selection_next,
                        ["<C-p>"] = actions.move_selection_previous,
                        -- Completely disable horizontal movement
                        ["<Left>"] = actions.nop, -- Use nop instead of false
                        ["<Right>"] = actions.nop,
                        ["<C-h>"] = actions.nop,
                        ["<C-l>"] = actions.nop,
                        ["<Home>"] = actions.nop,
                        ["<End>"] = actions.nop,
                        ["<C-a>"] = actions.nop,
                        ["<C-e>"] = actions.nop,
                    },
                    n = {
                        ["q"] = actions.close,
                        ["j"] = actions.move_selection_next,
                        ["k"] = actions.move_selection_previous,
                        ["<Down>"] = actions.move_selection_next,
                        ["<Up>"] = actions.move_selection_previous,
                        -- Disable all horizontal movement in normal mode
                        ["h"] = actions.nop,
                        ["l"] = actions.nop,
                        ["<Left>"] = actions.nop,
                        ["<Right>"] = actions.nop,
                        ["0"] = actions.nop,
                        ["$"] = actions.nop,
                        ["^"] = actions.nop,
                        ["w"] = actions.nop,
                        ["b"] = actions.nop,
                        ["e"] = actions.nop,
                    },
                },
            },
            -- Specific picker configurations
            pickers = {
                find_files = {
                    wrap_results = true,
                    path_display = { "smart" },
                    layout_strategy = "vertical",
                    layout_config = {
                        vertical = {
                            prompt_position = "top",
                            mirror = false,
                            preview_height = 0.5,
                            results_height = 0.3,
                        },
                        width = 0.90,
                        height = 0.85,
                        preview_cutoff = 10,
                    },
                    results_height = 5, -- Max 5 file results
                    hidden = true, -- Show hidden files by default
                    no_ignore = true, -- Show files even if in .gitignore
                    -- Enable history for file searches
                    history = {
                        path = vim.fn.stdpath("data") .. "/telescope_history.sqlite3",
                        limit = 50,
                    },
                },
                live_grep = {
                    wrap_results = true,
                    path_display = { "smart" },
                    layout_strategy = "vertical",
                    layout_config = {
                        vertical = {
                            prompt_position = "top",
                            mirror = false,
                            preview_height = 0.5,
                            results_height = 0.3,
                        },
                        width = 0.90,
                        height = 0.85,
                        preview_cutoff = 10,
                    },
                    -- Enable history for live grep searches
                    history = {
                        path = vim.fn.stdpath("data") .. "/telescope_history.sqlite3",
                        limit = 50,
                    },
                },
                buffers = {
                    wrap_results = true,
                    path_display = { "smart" },
                    layout_strategy = "vertical",
                    layout_config = {
                        vertical = {
                            prompt_position = "top",
                            mirror = false,
                            preview_height = 0.5,
                            results_height = 0.3,
                        },
                        width = 0.90,
                        height = 0.85,
                        preview_cutoff = 10,
                    },
                    results_height = 5, -- Max 5 buffers
                },
                oldfiles = {
                    wrap_results = true,
                    path_display = { "smart" },
                    layout_strategy = "vertical",
                    layout_config = {
                        vertical = {
                            prompt_position = "top",
                            mirror = false,
                            preview_height = 0.5,
                            results_height = 0.3,
                        },
                        width = 0.90,
                        height = 0.85,
                        preview_cutoff = 10,
                    },
                    results_height = 5, -- Max 5 recent files
                    -- Enable history for recent files search
                    history = {
                        path = vim.fn.stdpath("data") .. "/telescope_history.sqlite3",
                        limit = 30,
                    },
                },
            },
        }
    end,
    config = function(_, opts)
        local telescope = require("telescope")
        telescope.setup(opts)

        -- Custom telescope functions that remember last search
        local last_searches = {}

        -- Custom find files with history
        _G.telescope_find_files_with_history = function()
            local builtin = require("telescope.builtin")
            builtin.find_files({
                default_text = last_searches.find_files or "",
                hidden = true, -- Show hidden files
                no_ignore = true, -- Show files even if in .gitignore
                attach_mappings = function(prompt_bufnr, map)
                    local action_state = require("telescope.actions.state")

                    -- Save search when closing
                    vim.api.nvim_create_autocmd("User", {
                        pattern = "TelescopePromptClose",
                        callback = function()
                            local picker = action_state.get_current_picker(prompt_bufnr)
                            if picker then
                                last_searches.find_files = picker:_get_prompt()
                            end
                        end,
                        once = true,
                    })

                    return true
                end,
            })
        end

        -- Custom live grep with history
        _G.telescope_live_grep_with_history = function()
            local builtin = require("telescope.builtin")
            builtin.live_grep({
                default_text = last_searches.live_grep or "",
                attach_mappings = function(prompt_bufnr, map)
                    local action_state = require("telescope.actions.state")

                    -- Save search when closing
                    vim.api.nvim_create_autocmd("User", {
                        pattern = "TelescopePromptClose",
                        callback = function()
                            local picker = action_state.get_current_picker(prompt_bufnr)
                            if picker then
                                last_searches.live_grep = picker:_get_prompt()
                            end
                        end,
                        once = true,
                    })

                    return true
                end,
            })
        end

        -- Custom oldfiles with history
        _G.telescope_oldfiles_with_history = function()
            local builtin = require("telescope.builtin")
            builtin.oldfiles({
                default_text = last_searches.oldfiles or "",
                attach_mappings = function(prompt_bufnr, map)
                    local action_state = require("telescope.actions.state")

                    -- Save search when closing
                    vim.api.nvim_create_autocmd("User", {
                        pattern = "TelescopePromptClose",
                        callback = function()
                            local picker = action_state.get_current_picker(prompt_bufnr)
                            if picker then
                                last_searches.oldfiles = picker:_get_prompt()
                            end
                        end,
                        once = true,
                    })

                    return true
                end,
            })
        end
    end,
}
