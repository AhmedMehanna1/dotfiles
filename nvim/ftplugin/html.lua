local format = require("utils.format-ftplugin")
format.setup_auto_format({ timeout_ms = 500, lsp_fallback = true })
format.setup_indent(2, true)
vim.opt_local.textwidth = 0
vim.opt_local.wrap = true
vim.opt_local.linebreak = true