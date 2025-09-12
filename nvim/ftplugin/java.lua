local format = require("utils.format-ftplugin")
format.setup_auto_format({ timeout_ms = 3000, lsp_fallback = true })
format.setup_indent(4, true)
vim.opt_local.textwidth = 120
