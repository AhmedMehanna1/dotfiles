return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "mason.nvim",
        "williamboman/mason-lspconfig.nvim",
    },
    opts = {
        diagnostics = {
            underline = true,
            update_in_insert = false,
            virtual_text = {
                spacing = 4,
                source = "if_many",
                prefix = "●",
            },
            severity_sort = true,
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = require("utils.icons").diagnostics.Error,
                    [vim.diagnostic.severity.WARN] = require("utils.icons").diagnostics.Warn,
                    [vim.diagnostic.severity.HINT] = require("utils.icons").diagnostics.Hint,
                    [vim.diagnostic.severity.INFO] = require("utils.icons").diagnostics.Info,
                },
            },
        },
        inlay_hints = {
            enabled = true,
        },
        capabilities = {},
        format = {
            formatting_options = nil,
            timeout_ms = nil,
        },
        servers = {
            lua_ls = {
                settings = {
                    Lua = {
                        runtime = {
                            version = "LuaJIT",
                        },
                        diagnostics = {
                            globals = { "vim" },
                        },
                        workspace = {
                            library = {
                                vim.env.VIMRUNTIME,
                                "${3rd}/luv/library",
                            },
                            checkThirdParty = false,
                        },
                        telemetry = {
                            enable = false,
                        },
                        completion = {
                            callSnippet = "Replace",
                        },
                    },
                },
            },
            pyright = {},
            gopls = {
                settings = {
                    gopls = {
                        gofumpt = true,
                        codelenses = {
                            gc_details = false,
                            generate = true,
                            regenerate_cgo = true,
                            run_govulncheck = true,
                            test = true,
                            tidy = true,
                            upgrade_dependency = true,
                            vendor = true,
                        },
                        hints = {
                            assignVariableTypes = true,
                            compositeLiteralFields = true,
                            compositeLiteralTypes = true,
                            constantValues = true,
                            functionTypeParameters = true,
                            parameterNames = true,
                            rangeVariableTypes = true,
                        },
                        analyses = {
                            fieldalignment = true,
                            nilness = true,
                            unusedparams = true,
                            unusedwrite = true,
                            useany = true,
                        },
                        usePlaceholders = true,
                        completeUnimported = true,
                        staticcheck = true,
                        directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
                        semanticTokens = true,
                    },
                },
            },
            ts_ls = {},
            -- Rust
            rust_analyzer = {
                settings = {
                    ["rust-analyzer"] = {
                        cargo = {
                            allFeatures = true,
                            loadOutDirsFromCheck = true,
                            runBuildScripts = true,
                        },
                        checkOnSave = {
                            allFeatures = true,
                            command = "clippy",
                            extraArgs = { "--no-deps" },
                        },
                        procMacro = {
                            enable = true,
                            ignored = {
                                ["async-trait"] = { "async_trait" },
                                ["napi-derive"] = { "napi" },
                                ["async-recursion"] = { "async_recursion" },
                            },
                        },
                    },
                },
            },
            -- C/C++
            clangd = {
                keys = {
                    { "<leader>cR", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
                },
                root_dir = function(fname)
                    return require("lspconfig.util").root_pattern(
                        "Makefile",
                        "configure.ac",
                        "configure.in",
                        "config.h.in",
                        "meson.build",
                        "meson_options.txt",
                        "build.ninja"
                    )(fname) or require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt")(
                        fname
                    ) or require("lspconfig.util").find_git_ancestor(fname)
                end,
                capabilities = {
                    offsetEncoding = { "utf-16" },
                },
                cmd = {
                    "clangd",
                    "--background-index",
                    "--clang-tidy",
                    "--header-insertion=iwyu",
                    "--completion-style=detailed",
                    "--function-arg-placeholders",
                    "--fallback-style=llvm",
                },
                init_options = {
                    usePlaceholders = true,
                    completeUnimported = true,
                    clangdFileStatus = true,
                },
            },
            -- C#
            omnisharp = {
                cmd = { "omnisharp" },
                settings = {
                    FormattingOptions = {
                        EnableEditorConfigSupport = true,
                        OrganizeImports = true,
                    },
                    MsBuild = {
                        LoadProjectsOnDemand = nil,
                    },
                    RoslynExtensionsOptions = {
                        EnableAnalyzersSupport = nil,
                        EnableImportCompletion = nil,
                        AnalyzeOpenDocumentsOnly = nil,
                    },
                    Sdk = {
                        IncludePrereleases = true,
                    },
                },
            },
            -- Kotlin
            kotlin_language_server = {
                settings = {
                    kotlin = {
                        completion = {
                            snippets = { enabled = true },
                        },
                        hover = { enabled = true },
                        hints = {
                            typeHints = true,
                            parameterHints = true,
                            chainingHints = true,
                        },
                    },
                },
            },
            -- Web technologies
            html = {
                filetypes = { "html", "twig", "hbs" },
            },
            cssls = {
                settings = {
                    css = {
                        validate = true,
                        lint = {
                            unknownAtRules = "ignore",
                        },
                    },
                    less = {
                        validate = true,
                    },
                    scss = {
                        validate = true,
                    },
                },
            },
            emmet_ls = {
                filetypes = {
                    "html",
                    "typescriptreact",
                    "javascriptreact",
                    "css",
                    "sass",
                    "scss",
                    "less",
                    "svelte",
                },
            },
            angularls = {},
            -- Docker
            dockerls = {
                settings = {
                    docker = {
                        languageserver = {
                            formatter = {
                                ignoreMultilineInstructions = true,
                            },
                        },
                    },
                },
            },
        },
        setup = {},
    },
    config = function(_, opts)
        local Util = require("utils")
        Util.format.register(Util.lsp.formatter())

        Util.lsp.on_attach(function(client, buffer)
            require("plugins.lsp.configs.keymaps").on_attach(client, buffer)
        end)

        local register_capability = vim.lsp.handlers["client/registerCapability"]

        vim.lsp.handlers["client/registerCapability"] = function(err, res, ctx)
            local ret = register_capability(err, res, ctx)
            local client_id = ctx.client_id
            local client = vim.lsp.get_client_by_id(client_id)
            local buffer = vim.api.nvim_get_current_buf()
            require("plugins.lsp.configs.keymaps").on_attach(client, buffer)
            return ret
        end

        if opts.inlay_hints.enabled then
            Util.lsp.on_attach(function(client, buffer)
                if client.supports_method("textDocument/inlayHint") then
                    Util.toggle.inlay_hints(buffer, true)
                end
            end)
        end

        if type(opts.diagnostics.virtual_text) == "table" and opts.diagnostics.virtual_text.prefix == "icons" then
            opts.diagnostics.virtual_text.prefix = vim.fn.has("nvim-0.10.0") == 0 and "●"
                or function(diagnostic)
                    local icons = require("utils.icons").diagnostics
                    for d, icon in pairs(icons) do
                        if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
                            return icon
                        end
                    end
                end
        end

        vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

        local servers = opts.servers
        local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            has_cmp and cmp_nvim_lsp.default_capabilities() or {},
            opts.capabilities or {}
        )

        local function setup(server)
            local server_opts = vim.tbl_deep_extend("force", {
                capabilities = vim.deepcopy(capabilities),
            }, servers[server] or {})

            if opts.setup[server] then
                if opts.setup[server](server, server_opts) then
                    return
                end
            elseif opts.setup["*"] then
                if opts.setup["*"](server, server_opts) then
                    return
                end
            end
            require("lspconfig")[server].setup(server_opts)
        end

        local have_mason, mlsp = pcall(require, "mason-lspconfig")
        local all_mslp_servers = {}
        if have_mason then
            -- Safe way to get server mappings
            local ok, mappings = pcall(function()
                return require("mason-lspconfig.mappings.server").lspconfig_to_package
            end)
            if ok and mappings then
                all_mslp_servers = vim.tbl_keys(mappings)
            else
                -- Fallback for newer versions or if mappings don't exist
                all_mslp_servers = mlsp.get_available_servers()
            end
        end

        local ensure_installed = {}
        for server, server_opts in pairs(servers) do
            if server_opts then
                server_opts = server_opts == true and {} or server_opts
                if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
                    setup(server)
                else
                    ensure_installed[#ensure_installed + 1] = server
                end
            end
        end

        if have_mason then
            mlsp.setup({ ensure_installed = ensure_installed, handlers = { setup } })
        end

        -- Updated deprecated tsserver handling
        if Util.lsp.get_config("denols") and Util.lsp.get_config("ts_ls") then
            local is_deno = require("lspconfig.util").root_pattern("deno.json", "deno.jsonc")
            Util.lsp.disable("ts_ls", is_deno)
            Util.lsp.disable("denols", function(root_dir)
                return not is_deno(root_dir)
            end)
        end

        -- Java-specific LSP handling - ensure JDTLS attaches to all Java files
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "java",
            callback = function(args)
                local buf = args.buf

                -- Give nvim-java time to attach, then check
                vim.defer_fn(function()
                    local clients = vim.lsp.get_active_clients({ bufnr = buf })
                    local jdtls_attached = false

                    for _, client in ipairs(clients) do
                        if client.name == "jdtls" then
                            jdtls_attached = true
                            break
                        end
                    end

                    if not jdtls_attached then
                        -- Try to manually attach JDTLS
                        local jdtls_clients = vim.lsp.get_active_clients({ name = "jdtls" })
                        if #jdtls_clients > 0 then
                            -- JDTLS is running but not attached to this buffer
                            vim.lsp.buf_attach_client(buf, jdtls_clients[1].id)
                        else
                            -- No JDTLS client at all
                            vim.notify("JDTLS not running. Use :JavaLspRestart or restart Neovim.", vim.log.levels.WARN)
                        end
                    end
                end, 1000) -- Wait 1 second for nvim-java to do its thing
            end,
        })
    end,
}
