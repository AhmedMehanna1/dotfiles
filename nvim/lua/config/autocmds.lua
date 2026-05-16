-- Turn off paste mode when leaving insert
vim.api.nvim_create_autocmd("InsertLeave", {
    pattern = "*",
    command = "set nopaste",
})

-- Disable the concealing in some file formats
-- The default conceallevel is 3 in LazyVim
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "json", "jsonc", "markdown" },
    callback = function()
        vim.opt.conceallevel = 0
    end,
})

-- Java: IntelliJ profile uses 4 spaces; match editor indentation
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "java" },
    callback = function()
        vim.bo.expandtab = true
        vim.bo.shiftwidth = 4
        vim.bo.tabstop = 4
        vim.bo.softtabstop = 0
    end,
})
