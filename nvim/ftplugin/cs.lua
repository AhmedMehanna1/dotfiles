local format = require("utils.format-ftplugin")
format.setup_auto_format({ timeout_ms = 2000, lsp_fallback = true })
format.setup_indent(4, true)
vim.opt_local.textwidth = 120
vim.opt_local.colorcolumn = "120"

-- C#-specific keymaps (buffer-local)
local map = vim.keymap.set
local opts = { buffer = true, noremap = true, silent = true }

map("n", "<leader>cd", "<cmd>OmniSharpGotoDefinition<cr>", vim.tbl_extend("force", opts, { desc = "C#: Go to Definition" }))
map("n", "<leader>ci", "<cmd>OmniSharpFindImplementations<cr>", vim.tbl_extend("force", opts, { desc = "C#: Find Implementations" }))
map("n", "<leader>ct", "<cmd>OmniSharpFindType<cr>", vim.tbl_extend("force", opts, { desc = "C#: Find Type" }))
map("n", "<leader>cs", "<cmd>OmniSharpFindSymbol<cr>", vim.tbl_extend("force", opts, { desc = "C#: Find Symbol" }))
map("n", "<leader>cu", "<cmd>OmniSharpFindUsages<cr>", vim.tbl_extend("force", opts, { desc = "C#: Find Usages" }))
map("n", "<leader>cr", function() require("utils.rename").smart() end, vim.tbl_extend("force", opts, { desc = "C#: Rename" }))
map("n", "<leader>cf", "<cmd>OmniSharpCodeFormat<cr>", vim.tbl_extend("force", opts, { desc = "C#: Format Code" }))
map("n", "<leader>cb", "<cmd>OmniSharpBuild<cr>", vim.tbl_extend("force", opts, { desc = "C#: Build" }))
map("n", "<leader>cB", "<cmd>OmniSharpBuildAsync<cr>", vim.tbl_extend("force", opts, { desc = "C#: Build Async" }))
map("n", "<leader>cR", "<cmd>OmniSharpRestartServer<cr>", vim.tbl_extend("force", opts, { desc = "C#: Restart Server" }))
