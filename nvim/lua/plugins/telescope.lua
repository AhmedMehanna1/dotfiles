return {
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
            "nvim-tree/nvim-web-devicons",
            "folke/todo-comments.nvim",
        },
        config = function()
            local telescope = require("telescope")
            local actions = require("telescope.actions")
            local transform_mod = require("telescope.actions.mt").transform_mod

            local trouble = require("trouble")
            local trouble_telescope = require("trouble.sources.telescope")

            -- or create your custom action
            local custom_actions = transform_mod({
                open_trouble_qflist = function(prompt_bufnr)
                    trouble.toggle("quickfix")
                end,
            })

            telescope.setup({
                defaults = {
                    path_display = { "smart" },
                    mappings = {
                        i = {
                            ["<C-k>"] = actions.move_selection_previous, -- move to prev result
                            ["<C-j>"] = actions.move_selection_next, -- move to next result
                            ["<C-q>"] = actions.send_selected_to_qflist + custom_actions.open_trouble_qflist,
                            ["<C-t>"] = trouble_telescope.open,
                        },
                    },
                },
            })

            telescope.load_extension("fzf")

            -- set keymaps
            local keymap = vim.keymap -- for conciseness

            keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
            keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
            keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
            keymap.set(
                "n",
                "<leader>fc",
                "<cmd>Telescope grep_string<cr>",
                { desc = "Find string under cursor in cwd" }
            )
            keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
        end,
    },

    --     {
    --         "nvim-telescope/telescope-ui-select.nvim",
    --         config = function()
    --             -- get access to telescopes navigation functions
    --             local actions = require("telescope.actions")
    --             local icons = require("config.icons")
    --
    --             require("telescope").setup({
    --                 -- use ui-select dropdown as our ui
    --                 extensions = {
    --                     ["ui-select"] = {
    --                         require("telescope.themes").get_dropdown({}),
    --                     },
    --                     fzf = {
    --                         fuzzy = true, -- false will only do exact matching
    --                         override_generic_sorter = true, -- override the generic sorter
    --                         override_file_sorter = true, -- override the file sorter
    --                         case_mode = "smart_case", -- or "ignore_case" or "respect_case"
    --                     },
    --                 },
    --                 defaults = {
    --                     prompt_prefix = icons.ui.Telescope .. " ",
    --                     selection_caret = icons.ui.Forward .. " ",
    --                     entry_prefix = "   ",
    --                     initial_mode = "insert",
    --                     selection_strategy = "reset",
    --                     path_display = { "smart" },
    --                     color_devicons = true,
    --                     vimgrep_arguments = {
    --                         "rg",
    --                         "--color=never",
    --                         "--no-heading",
    --                         "--with-filename",
    --                         "--line-number",
    --                         "--column",
    --                         "--smart-case",
    --                         "--hidden",
    --                         "--glob=!.git/",
    --                     },
    --                 },
    --                 -- set keymappings to navigate through items in the telescope io
    --                 mappings = {
    --                     i = {
    --                         ["<C-n>"] = actions.cycle_history_next,
    --                         ["<C-p>"] = actions.cycle_history_prev,
    --
    --                         ["<C-j>"] = actions.move_selection_next,
    --                         ["<C-k>"] = actions.move_selection_previous,
    --                     },
    --                     n = {
    --                         ["<esc>"] = actions.close,
    --                         ["j"] = actions.move_selection_next,
    --                         ["k"] = actions.move_selection_previous,
    --                         ["q"] = actions.close,
    --                     },
    --                 },
    --                 pickers = {
    --                     live_grep = {
    --                         theme = "dropdown",
    --                     },
    --
    --                     grep_string = {
    --                         theme = "dropdown",
    --                     },
    --
    --                     find_files = {
    --                         theme = "dropdown",
    --                         previewer = false,
    --                     },
    --
    --                     buffers = {
    --                         theme = "dropdown",
    --                         previewer = false,
    --                         initial_mode = "normal",
    --                         mappings = {
    --                             i = {
    --                                 ["<C-d>"] = actions.delete_buffer,
    --                             },
    --                             n = {
    --                                 ["dd"] = actions.delete_buffer,
    --                             },
    --                         },
    --                     },
    --
    --                     planets = {
    --                         show_pluto = true,
    --                         show_moon = true,
    --                     },
    --
    --                     colorscheme = {
    --                         enable_preview = true,
    --                     },
    --
    --                     lsp_references = {
    --                         theme = "dropdown",
    --                         initial_mode = "normal",
    --                     },
    --
    --                     lsp_definitions = {
    --                         theme = "dropdown",
    --                         initial_mode = "normal",
    --                     },
    --
    --                     lsp_declarations = {
    --                         theme = "dropdown",
    --                         initial_mode = "normal",
    --                     },
    --
    --                     lsp_implementations = {
    --                         theme = "dropdown",
    --                         initial_mode = "normal",
    --                     },
    --                 },
    --             })
    --             -- load the ui-select extension
    --             require("telescope").load_extension("ui-select")
    --         end,
    --     },
}
