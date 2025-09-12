local format = require('utils.format-ftplugin')

format.setup_auto_format({ timeout_ms = 500 })

-- TypeScript-specific settings
vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
