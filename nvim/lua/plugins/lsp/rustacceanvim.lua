return {
    "mrcjkb/rustaceanvim",
    version = "^5",
    lazy = false,
    config = function()
        vim.g.rustaceanvim = {
            inlay_hints = {
                highlight = "NonText",
            },
            tools = {
                hover_actions = {
                    auto_focus = true,
                },
            },
            server = {
                on_attach = function(client, bufnr)
                    require("plugins.lsp.configs.keymaps").on_attach(client, bufnr)
                end,
                settings = {
                    ["rust-analyzer"] = {
                        cargo = {
                            allFeatures = true,
                            loadOutDirsFromCheck = true,
                            buildScripts = {
                                enable = true,
                            },
                        },
                        check = {
                            command = "clippy",
                            extraArgs = { "-all-features" },
                            allTargets = false,
                        },
                        procMacro = {
                            enable = true,
                            ignored = {
                                ["async-trait"] = { "async_trait" },
                                ["napi-derive"] = { "napi" },
                                ["async-recursion"] = { "async_recursion" },
                            },
                        },
                        diagnostics = {
                            enable = true,
                            experimental = {
                                enable = true,
                            },
                        },
                    },
                },
            },
            dap = {
                adapter = require("rustaceanvim.config").get_codelldb_adapter(
                    vim.fn.stdpath("data") .. "/mason/bin/codelldb",
                    vim.fn.stdpath("data")
                        .. "/mason/packages/codelldb/extension/lldb/lib/liblldb"
                        .. (vim.fn.has("mac") == 1 and ".dylib" or ".so")
                ),
            },
        }
    end,
}
