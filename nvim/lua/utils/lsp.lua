local M = {}

function M.get_clients(opts)
    local ret = {} ---@type lsp.Client[]
    if vim.lsp.get_clients then
        ret = vim.lsp.get_clients(opts)
    else
        ---@diagnostic disable-next-line: deprecated
        ret = vim.lsp.get_active_clients(opts)
        if opts and opts.method then
            ret = vim.tbl_filter(function(client)
                return client.supports_method(opts.method, { bufnr = opts.bufnr })
            end, ret)
        end
    end
    return opts and opts.filter and vim.tbl_filter(opts.filter, ret) or ret
end

---@param on_attach fun(client, buffer)
function M.on_attach(on_attach)
    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
            local buffer = args.buf ---@type number
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            on_attach(client, buffer)
        end,
    })
end

---@param name string
---@param fn fun(name:string)
function M.on_dynamic_capability(fn)
    return vim.lsp.handlers["client/registerCapability"](function(err, res, ctx)
        ---@type lsp.Client
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        local buffer = vim.api.nvim_get_current_buf()
        if client then
            fn(client, buffer)
        end
    end)
end

---@type table<string, table<vim.lsp.Client, table<number, boolean>>>
M._supports_method = {}

function M.setup()
    local register_capability = vim.lsp.handlers["client/registerCapability"]
    vim.lsp.handlers["client/registerCapability"] = function(err, res, ctx)
        local ret = register_capability(err, res, ctx)
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        if client then
            for buffer in pairs(client.attached_buffers) do
                vim.api.nvim_exec_autocmds("User", {
                    pattern = "LspDynamicCapability",
                    data = { client_id = client.id, buffer = buffer },
                })
            end
        end
        return ret
    end
    M.on_attach(M._check_methods)
    M.on_dynamic_capability(M._check_methods)
end

function M._check_methods(client, buffer)
    if not vim.api.nvim_buf_is_valid(buffer) then
        return
    end
    if not vim.bo[buffer].buflisted then
        return
    end
    if vim.bo[buffer].buftype ~= "" then
        return
    end
    for method, clients in pairs(M._supports_method) do
        clients[client] = clients[client] or {}
        if not clients[client][buffer] then
            if client.supports_method and client.supports_method(method, { bufnr = buffer }) then
                clients[client][buffer] = true
                vim.api.nvim_exec_autocmds("User", {
                    pattern = "LspSupportsMethod",
                    data = { client_id = client.id, buffer = buffer, method = method },
                })
            end
        end
    end
end

---@param method string
function M.on_supports_method(method, fn)
    M._supports_method[method] = M._supports_method[method] or setmetatable({}, { __mode = "k" })
    vim.api.nvim_create_autocmd("User", {
        pattern = "LspSupportsMethod",
        callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            local buffer = args.data.buffer ---@type number
            if args.data.method == method then
                return fn(client, buffer)
            end
        end,
    })
end

---@return _.lspconfig.options
function M.get_config(server)
    local configs = require("lspconfig.configs")
    return rawget(configs, server)
end

---@param server string
---@param cond fun( root_dir, config): boolean
function M.disable(server, cond)
    local util = require("lspconfig.util")
    local def = M.get_config(server)
    ---@diagnostic disable-next-line: undefined-field
    def.document_config.on_new_config = util.add_hook_before(
        def.document_config.on_new_config,
        function(config, root_dir)
            if cond(root_dir, config) then
                config.enabled = false
            end
        end
    )
end

---@param opts? LazyFormatter| {filter?: (string|lsp.Client.filter)}
function M.formatter(opts)
    opts = opts or {}
    local filter = opts.filter or {}
    filter = type(filter) == "string" and { name = filter } or filter
    ---@cast filter lsp.Client.filter
    ---@type LazyFormatter
    local ret = {
        name = "LSP",
        primary = true,
        priority = 1,
        format = function(buf)
            M.format(vim.tbl_deep_extend("force", {
                bufnr = buf,
                filter = function(client)
                    return not (client.name == "null-ls")
                end,
            }, filter))
        end,
        sources = function(buf)
            local clients = M.get_clients(vim.tbl_deep_extend("force", { bufnr = buf }, filter))
            ---@param client lsp.Client
            local ret = vim.tbl_map(function(client)
                return {
                    id = "lsp",
                    name = client.name,
                    source = "LSP",
                    available = function()
                        return client.supports_method("textDocument/formatting")
                            or client.supports_method("textDocument/rangeFormatting")
                    end,
                }
            end, clients)
            return ret
        end,
    }
    return ret
end

function M.format(opts)
    opts = vim.tbl_deep_extend("force", {}, opts or {})
    local ok, conform = pcall(require, "conform")
    if ok then
        opts.formatters = {}
        opts.lsp_fallback = true
        conform.format(opts)
    else
        vim.lsp.buf.format(opts)
    end
end

M.words = {}

---@param opts {enabled?: boolean}
function M.words.setup(opts)
    opts = opts or {}
    if not opts.enabled then
        return
    end

    local handler = vim.lsp.handlers["textDocument/documentHighlight"]
    vim.lsp.handlers["textDocument/documentHighlight"] = function(err, result, ctx, config)
        if not vim.api.nvim_buf_is_loaded(ctx.bufnr) then
            return
        end
        return handler(err, result, ctx, config)
    end

    M.on_supports_method("textDocument/documentHighlight", function(_, buf)
        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", "CursorMoved", "CursorMovedI" }, {
            group = vim.api.nvim_create_augroup("lsp_word_" .. buf, { clear = true }),
            buffer = buf,
            callback = function(ev)
                if not require("utils").has("vim-illuminate") then
                    if ev.event:find("CursorMoved") then
                        vim.lsp.buf.clear_references()
                    else
                        vim.lsp.buf.document_highlight()
                    end
                end
            end,
        })
    end)
end

-- Add this function to handle the tsserver -> ts_ls transition
function M.setup_typescript()
    -- Handle the tsserver -> ts_ls transition
    if M.get_config("ts_ls") and M.get_config("denols") then
        local is_deno = require("lspconfig.util").root_pattern("deno.json", "deno.jsonc")
        M.disable("ts_ls", is_deno)
        M.disable("denols", function(root_dir)
            return not is_deno(root_dir)
        end)
    end

    -- Legacy support - if someone still has tsserver configured
    if M.get_config("tsserver") then
        vim.notify("tsserver is deprecated, please use ts_ls instead", vim.log.levels.WARN)
        M.disable("tsserver", function()
            return true
        end) -- Always disable old tsserver
    end
end

return M
