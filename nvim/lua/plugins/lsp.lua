return {
  -- tools
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "stylua",
        "selene",
        "luacheck",
        "shellcheck",
        "shfmt",
        "tailwindcss-language-server",
        "typescript-language-server",
        "css-lsp",
        -- java
        "jdtls",
        "lemminx",
        "groovy-language-server",
        "kotlin-language-server",
        -- rust
        "rust-analyzer",
        "codelldb",
        -- go
        "gopls",
        "gofumpt",
        "golangci-lint",
        "delve",
        -- c / c++
        "clangd",
        "clang-format",
        -- angular
        "angular-language-server",
        -- html / json / xml / yaml / toml
        "html-lsp",
        "json-lsp",
        "yaml-language-server",
        "taplo",
      })
    end,
  },

  -- lsp servers
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      ---@type lspconfig.options
      servers = {
        cssls = {},
        tailwindcss = {
          root_dir = function(...)
            return require("lspconfig.util").root_pattern(".git")(...)
          end,
        },
        tsserver = {
          root_dir = function(...)
            return require("lspconfig.util").root_pattern(".git")(...)
          end,
          single_file_support = false,
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "literal",
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
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          },
        },
        html = {},
        yamlls = {
          settings = {
            yaml = {
              keyOrdering = false,
            },
          },
        },
        lua_ls = {
          -- enabled = false,
          single_file_support = true,
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                workspaceWord = true,
                callSnippet = "Both",
              },
              misc = {
                parameters = {
                  -- "--log-level=trace",
                },
              },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
              doc = {
                privateName = { "^_" },
              },
              type = {
                castNumberToInteger = true,
              },
              diagnostics = {
                disable = { "incomplete-signature-doc", "trailing-space" },
                -- enable = false,
                groupSeverity = {
                  strong = "Warning",
                  strict = "Warning",
                },
                groupFileStatus = {
                  ["ambiguity"] = "Opened",
                  ["await"] = "Opened",
                  ["codestyle"] = "None",
                  ["duplicate"] = "Opened",
                  ["global"] = "Opened",
                  ["luadoc"] = "Opened",
                  ["redefined"] = "Opened",
                  ["strict"] = "Opened",
                  ["strong"] = "Opened",
                  ["type-check"] = "Opened",
                  ["unbalanced"] = "Opened",
                  ["unused"] = "Opened",
                },
                unusedLocalExclude = { "_*" },
              },
              format = {
                enable = false,
                defaultConfig = {
                  indent_style = "space",
                  indent_size = "2",
                  continuation_indent_size = "2",
                },
              },
            },
          },
        },
        lemminx = {
          init_options = {
            settings = {
              xml = {
                format = {
                  enabled = true,
                  splitAttributes = "alignWithFirstAttr", -- keeps multi-attr tags split across lines
                  --splitAttributes = "preserve", -- keeps multi-attr tags split across lines
                  preservedNewlines = 2, -- allows up to 2 empty lines to be kept
                  joinContentLines = false,
                  joinCommentLines = false,
                  maxLineWidth = 120,
                  tabSize = 4,
                  insertSpaces = true,
                },
              },
            },
          },
        },
      },
      setup = {},
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      vim.list_extend(keys, {
        {
          "gd",
          function()
            local params = vim.lsp.util.make_position_params()
            vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result)
              if err then
                vim.notify("Error: " .. err.message, vim.log.levels.ERROR)
                return
              end
              if not result or vim.tbl_isempty(result) then
                vim.notify("No definition found", vim.log.levels.WARN)
                return
              end
              local target = vim.tbl_islist(result) and result[1] or result
              local target_uri = target.uri or target.targetUri
              local target_path = vim.uri_to_fname(target_uri)
              -- Search all windows/tabs for already-open file
              for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
                for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
                  local buf = vim.api.nvim_win_get_buf(win)
                  local buf_path = vim.api.nvim_buf_get_name(buf)
                  if buf_path == target_path then
                    vim.api.nvim_set_current_tabpage(tab)
                    vim.api.nvim_set_current_win(win)
                    -- Move cursor to definition line
                    local range = target.range or target.targetSelectionRange
                    if range then
                      vim.api.nvim_win_set_cursor(win, {
                        range.start.line + 1,
                        range.start.character,
                      })
                    end
                    return
                  end
                end
              end
              -- Not open anywhere: open in new tab
              vim.cmd("tabnew " .. vim.fn.fnameescape(target_path))
              -- Move cursor to definition line
              local range = target.range or target.targetSelectionRange
              if range then
                vim.api.nvim_win_set_cursor(0, {
                  range.start.line + 1,
                  range.start.character,
                })
              end
            end)
          end,
          desc = "Goto Definition",
          has = "definition",
        },
      })
    end,
  },
}
