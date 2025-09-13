-- Docker Compose specific settings
local format = require("utils.format-ftplugin")
format.setup_auto_format({ timeout_ms = 500, lsp_fallback = true })
format.setup_indent(2, true)

-- Set filetype for docker-compose files
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = {"docker-compose*.yml", "docker-compose*.yaml", "compose.yml", "compose.yaml"},
    callback = function()
        vim.bo.filetype = "yaml.docker-compose"
    end,
})

-- Add helpful keymaps for Docker Compose
local keymap = vim.keymap
keymap.set("n", "<leader>du", "<cmd>!docker-compose up -d<cr>", { desc = "Docker Compose Up", buffer = true })
keymap.set("n", "<leader>dd", "<cmd>!docker-compose down<cr>", { desc = "Docker Compose Down", buffer = true })
keymap.set("n", "<leader>dr", "<cmd>!docker-compose restart<cr>", { desc = "Docker Compose Restart", buffer = true })
keymap.set("n", "<leader>dl", "<cmd>!docker-compose logs -f<cr>", { desc = "Docker Compose Logs", buffer = true })