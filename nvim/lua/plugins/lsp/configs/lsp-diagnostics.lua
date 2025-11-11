local M = {}

-- filter diagnostics for Java (remove style-only warnings)
function M.filter_java()
    vim.diagnostic.handlers.virtual_text = {
        show = function(namespace, bufnr, diagnostics, opts)
            local filtered = {}
            for _, d in ipairs(diagnostics) do
                if
                    not (
                        d.message:match("indentation")
                        or d.message:match("curly")
                        or d.message:match("Javadoc")
                        or d.message:match("import")
                        or d.message:match("Line is longer than")
                    )
                then
                    table.insert(filtered, d)
                end
            end
            vim.diagnostic.handlers.virtual_text.old_show(namespace, bufnr, filtered, opts)
        end,
        hide = function(namespace, bufnr)
            vim.diagnostic.handlers.virtual_text.old_hide(namespace, bufnr)
        end,
        old_show = vim.diagnostic.handlers.virtual_text.show,
        old_hide = vim.diagnostic.handlers.virtual_text.hide,
    }

    vim.diagnostic.handlers.signs = {
        show = function(namespace, bufnr, diagnostics, opts)
            local filtered = {}
            for _, d in ipairs(diagnostics) do
                if
                    not (
                        d.message:match("indentation")
                        or d.message:match("curly")
                        or d.message:match("Javadoc")
                        or d.message:match("import")
                        or d.message:match("Line is longer than")
                    )
                then
                    table.insert(filtered, d)
                end
            end
            vim.diagnostic.handlers.signs.old_show(namespace, bufnr, filtered, opts)
        end,
        hide = function(namespace, bufnr)
            vim.diagnostic.handlers.signs.old_hide(namespace, bufnr)
        end,
        old_show = vim.diagnostic.handlers.signs.show,
        old_hide = vim.diagnostic.handlers.signs.hide,
    }

    vim.diagnostic.handlers.underline = {
        show = function(namespace, bufnr, diagnostics, opts)
            local filtered = {}
            for _, d in ipairs(diagnostics) do
                if
                    not (
                        d.message:match("indentation")
                        or d.message:match("curly")
                        or d.message:match("Javadoc")
                        or d.message:match("import")
                        or d.message:match("Line is longer than")
                        or d.message:match("unused")
                        or d.message:match("never used")
                    )
                then
                    table.insert(filtered, d)
                end
            end
            vim.diagnostic.handlers.underline.old_show(namespace, bufnr, filtered, opts)
        end,
        hide = function(namespace, bufnr)
            vim.diagnostic.handlers.underline.old_hide(namespace, bufnr)
        end,
        old_show = vim.diagnostic.handlers.underline.show,
        old_hide = vim.diagnostic.handlers.underline.hide,
    }
end

return M
