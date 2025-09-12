local format = require('utils.format-ftplugin')

format.setup_auto_format({ timeout_ms = 1000 })
format.setup_indent(4)

vim.opt_local.textwidth = 88
