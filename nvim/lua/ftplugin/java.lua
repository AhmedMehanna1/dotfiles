local format = require('utils.format-ftplugin')

format.setup_auto_format({ timeout_ms = 1500 })

-- Java-specific settings
vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4
vim.opt_local.textwidth = 120
