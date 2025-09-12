local format = require('utils.format-ftplugin')

format.setup_auto_format({ timeout_ms = 800 })

-- Go-specific: uses tabs, not spaces
vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4
vim.opt_local.expandtab = false
