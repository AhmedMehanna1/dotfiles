-- Load core configuration
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- Load Java LSP fix
require("config.java-fix").setup()
