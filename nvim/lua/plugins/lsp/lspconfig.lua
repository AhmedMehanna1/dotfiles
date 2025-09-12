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
            gopls = {},
            ts_ls = {},
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
    end,
}
