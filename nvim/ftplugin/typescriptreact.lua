local format = require("utils.format-ftplugin")
format.setup_auto_format({ timeout_ms = 500, lsp_fallback = true })
format.setup_indent(2, true)

-- React-specific settings
vim.opt_local.suffixesadd:prepend(".tsx,.ts,.jsx,.js")
vim.opt_local.includeexpr = "substitute(v:fname,'\\.','/','g')"