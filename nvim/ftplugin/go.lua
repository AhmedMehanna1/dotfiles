local format = require("utils.format-ftplugin")
format.setup_auto_format({ timeout_ms = 800, lsp_fallback = true })
format.setup_indent(4, true)
