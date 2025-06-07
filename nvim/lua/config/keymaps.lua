vim.g.mapleader = " "

local keymap = vim.keymap

keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })   -- split window horizontally
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })     -- split window vertically
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })      -- make split windows equal width & height
keymap.set("n", "<leader>ss", "<C-w>W", { desc = "Switch window" })               -- switch window
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window
keymap.set("n", "<leader>sdh", "<C-w>-", { desc = "Decrease split height" })
keymap.set("n", "<leader>sih", "<C-w>+", { desc = "Increase split height" })
keymap.set("n", "<leader>sdw", "<C-w><", { desc = "Decrease split width" })
keymap.set("n", "<leader>siw", "<C-w>>", { desc = "Increase split width" })

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })                     -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })              -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })                     --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })                 --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

vim.cmd("nnoremap <silent> <C-j> :m .+1<CR>==")
vim.cmd("nnoremap <silent> <C-k> :m .-2<CR>==")
vim.cmd("inoremap <silent> <C-j> <Esc>:m .+1<CR>==gi")
vim.cmd("inoremap <silent> <C-k> <Esc>:m .-2<CR>==gi")
vim.cmd("vnoremap <silent> <C-j> :m '>+1<CR>gv=gv")
vim.cmd("vnoremap <silent> <C-k> :m '<-2<CR>gv=gv")
