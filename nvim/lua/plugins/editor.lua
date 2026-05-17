return {
  {
    enabled = false,
    "folke/flash.nvim",
    ---@type Flash.Config
    opts = {
      search = {
        forward = true,
        multi_window = false,
        wrap = false,
        incremental = true,
      },
    },
    keys = {
      { "s", false },
      
        "A-s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
      },
    },
  },

  {
    "brenoprata10/nvim-highlight-colors",
    event = "BufReadPre",
    opts = {
      render = "background",
      enable_hex = true,
      enable_short_hex = true,
      enable_rgb = true,
      enable_hsl = true,
      enable_hsl_without_function = true,
      enable_ansi = true,
      enable_var_usage = true,
      enable_tailwind = true,
    },
  },

  {
    "dinhhuy258/git.nvim",
    event = "BufReadPre",
    opts = {
      keymaps = {
        -- Open blame window
        blame = "<Leader>gb",
        -- Open file/folder in git repository
        browse = "<Leader>go",
      },
    },
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
      "nvim-telescope/telescope-file-browser.nvim",
    },
    keys = {
      {
        "<leader>fP",
        function()
          require("telescope.builtin").find_files({
            cwd = require("lazy.core.config").options.root,
          })
        end,
        desc = "Find Plugin File",
      },
      -- ── File Navigation (mirrors ideavimrc) ──────────────────────────
      {
        "<leader>ff",
        function()
          require("telescope.builtin").find_files({
            no_ignore = false,
            hidden = true,
          })
        end,
        desc = "GotoFile – Lists files in current working directory",
      },
      {
        "<leader>fs",
        function()
          require("telescope.builtin").live_grep({
            additional_args = { "--hidden" },
          })
        end,
        desc = "FindInPath – Search for a string in the current working directory",
      },
      {
        "<leader>fc",
        function()
          local builtin = require("telescope.builtin")
          -- Try LSP workspace symbols first (closest to GotoClass)
          local clients = vim.lsp.get_clients({ bufnr = 0 })
          if #clients > 0 then
            builtin.lsp_workspace_symbols({
              symbols = {
                "Class",
                "Struct",
                "Interface",
                "Module",
                "Namespace",
                "Enum",
              },
            })
          else
            -- Fallback to Treesitter if no LSP
            builtin.treesitter({
              default_selection_index = 1,
            })
          end
        end,
        desc = "GotoClass – Lists class/struct symbols, falls back to Treesitter",
      },
      {
        "<leader>fS",
        function()
          require("telescope.builtin").lsp_workspace_symbols()
        end,
        desc = "GotoSymbol – Lists all symbols in the workspace via LSP",
      },
      {
        "<leader>fr",
        function()
          require("telescope.builtin").oldfiles()
        end,
        desc = "RecentFiles – Lists previously opened files",
      },
      -- ── Refactoring ──────────────────────────────────────────────────
      -- <leader>re  → RenameElement  handled by LSP keymap (see note below)
      -- <leader>rf  → RenameFile     handled by telescope-file-browser or neo-tree
      -- <leader>rp  → ReplaceInPath  handled by nvim-spectre
      -- ── Original keymaps (kept) ──────────────────────────────────────
      {
        ";f",
        function()
          require("telescope.builtin").find_files({
            no_ignore = false,
            hidden = true,
          })
        end,
        desc = "Lists files in your current working directory, respects .gitignore",
      },
      {
        ";r",
        function()
          require("telescope.builtin").live_grep({
            additional_args = { "--hidden" },
          })
        end,
        desc = "Search for a string in your current working directory and get results live as you type, respects .gitignore",
      },
      {
        "\\\\",
        function()
          require("telescope.builtin").buffers()
        end,
        desc = "Lists open buffers",
      },
      {
        ";t",
        function()
          require("telescope.builtin").help_tags()
        end,
        desc = "Lists available help tags and opens a new window with the relevant help info on <cr>",
      },
      {
        ";;",
        function()
          require("telescope.builtin").resume()
        end,
        desc = "Resume the previous telescope picker",
      },
      {
        ";e",
        function()
          require("telescope.builtin").diagnostics()
        end,
        desc = "Lists Diagnostics for all open buffers or a specific buffer",
      },
      {
        ";s",
        function()
          require("telescope.builtin").treesitter()
        end,
        desc = "Lists Function names, variables, from Treesitter",
      },
      {
        ";c",
        function()
          require("telescope.builtin").lsp_incoming_calls()
        end,
        desc = "Lists LSP incoming calls for word under the cursor",
      },
      {
        "sf",
        function()
          local telescope = require("telescope")
          local function telescope_buffer_dir()
            return vim.fn.expand("%:p:h")
          end
          telescope.extensions.file_browser.file_browser({
            path = "%:p:h",
            cwd = telescope_buffer_dir(),
            respect_gitignore = false,
            hidden = true,
            grouped = true,
            previewer = false,
            initial_mode = "normal",
            theme = "ivy",
            layout_config = { height = 40, width = 0.95 },
          })
        end,
        desc = "Open File Browser with the path of the current buffer",
      },
      {
        "<leader>rf",
        function()
          local state = require("telescope").extensions.file_browser.actions
          -- Opens file browser in normal mode so you can press `r` to rename
          require("telescope").extensions.file_browser.file_browser({
            path = "%:p:h",
            cwd = vim.fn.expand("%:p:h"),
            hidden = true,
            grouped = true,
            previewer = false,
            initial_mode = "normal",
            theme = "ivy",
            layout_config = { height = 40, width = 0.95 },
          })
        end,
        desc = "RenameFile – Open file browser to rename current file",
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local fb_actions = require("telescope").extensions.file_browser.actions

      opts.defaults = vim.tbl_deep_extend("force", opts.defaults, {
        wrap_results = true,
        layout_strategy = "flex",
        layout_config = { prompt_position = "top", width = 0.95 },
        sorting_strategy = "ascending",
        winblend = 0,
        mappings = {
          n = {},
        },
      })
      opts.pickers = {
        diagnostics = {
          theme = "ivy",
          initial_mode = "normal",
          layout_config = {
            preview_cutoff = 9999,
          },
        },
        file_browser = {
          layout_config = {
            width = 0.95,
            preview_cutoff = 9999,
          },
        },
      }
      opts.extensions = {
        file_browser = {
          theme = "ivy",
          hijack_netrw = true,
          layout_config = { width = 0.95 },
          mappings = {
            ["n"] = {
              ["N"] = fb_actions.create,
              ["h"] = fb_actions.goto_parent_dir,
              ["/"] = function()
                vim.cmd("startinsert")
              end,
              ["<C-u>"] = function(prompt_bufnr)
                for i = 1, 10 do
                  actions.move_selection_previous(prompt_bufnr)
                end
              end,
              ["<C-d>"] = function(prompt_bufnr)
                for i = 1, 10 do
                  actions.move_selection_next(prompt_bufnr)
                end
              end,
              ["<PageUp>"] = actions.preview_scrolling_up,
              ["<PageDown>"] = actions.preview_scrolling_down,
            },
          },
        },
      }
      telescope.setup(opts)
      require("telescope").load_extension("fzf")
      require("telescope").load_extension("file_browser")

      -- ── LSP rename (RenameElement) ───────────────────────────────────
      vim.keymap.set("n", "<leader>re", vim.lsp.buf.rename, {
        desc = "RenameElement – LSP rename symbol under cursor",
      })
    end,
  },

  {
    "kazhala/close-buffers.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>th",
        function()
          require("close_buffers").delete({ type = "hidden" })
        end,
        desc = "Close Hidden Buffers",
      },
      {
        "<leader>tu",
        function()
          require("close_buffers").delete({ type = "nameless" })
        end,
        desc = "Close Nameless Buffers",
      },
    },
  },

  -- ReplaceInPath  (<leader>rp)
  {
    "nvim-pack/nvim-spectre",
    keys = {
      {
        "<leader>rp",
        function()
          require("spectre").open()
        end,
        desc = "ReplaceInPath – Project-wide find & replace",
      },
    },
  },

  -- blink.cmp is configured via `lazyvim.plugins.extras.coding.blink`
}
