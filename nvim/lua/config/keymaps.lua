-- local discipline = require("craftzdog.discipline")
-- discipline.cowboy()

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Increment/decrement
keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")

-- New tab
keymap.set("n", "te", ":tabedit")
keymap.set("n", "<tab>", ":tabnext<Return>", opts)
keymap.set("n", "<s-tab>", ":tabprev<Return>", opts)
-- Split window
keymap.set("n", "ss", ":split<Return>", opts)
keymap.set("n", "sv", ":vsplit<Return>", opts)
-- Move window
keymap.set("n", "sh", "<C-w>h")
keymap.set("n", "sk", "<C-w>k")
keymap.set("n", "sj", "<C-w>j")
keymap.set("n", "sl", "<C-w>l")

-- Resize window
keymap.set("n", "<C-left>", "<C-w><")
keymap.set("n", "<C-right>", "<C-w>>")
keymap.set("n", "<C-up>", "<C-w>+")
keymap.set("n", "<C-down>", "<C-w>-")

-- Move lines
keymap.set("n", "<C-j>", ":m .+1<CR>==", opts)
keymap.set("n", "<C-k>", ":m .-2<CR>==", opts)
keymap.set({ "v", "s" }, "<C-j>", ":m '>+1<CR>gv=gv", opts)
keymap.set({ "v", "s" }, "<C-k>", ":m '<-2<CR>gv=gv", opts)

keymap.set("n", "<leader>rc", function()
    require("craftzdog.hsl").replaceHexWithHSL()
end, { desc = "Replace Hex with HSL" })

keymap.set("n", "<leader>i", function()
    require("craftzdog.lsp").toggleInlayHints()
end, { desc = "Toggle inlay hints" })

vim.api.nvim_create_user_command("ToggleAutoformat", function()
    require("craftzdog.lsp").toggleAutoformat()
end, {})

keymap.set("n", "<leader>xo", function()
    local current = vim.api.nvim_get_current_buf()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if buf ~= current and vim.api.nvim_buf_is_loaded(buf) then
            vim.api.nvim_buf_delete(buf, { force = false })
        end
    end
end, { desc = "Close all buffers except current" })
