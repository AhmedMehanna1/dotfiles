local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("config")
LazyVim = require("lazy")

LazyVim.setup({ { import = "plugins" }, { import = "plugins.lsp" } }, {
    checker = {
        enabled = true,
        notify = false,
    },
    change_detection = {
        notify = false,
    },
})

-- vim.keymap.set("n", "<leader>lh", "<cmd>Lazy<cr>", { desc = "Open up Lazy plugin manager" })
-- vim.keymap.set("n", "<leader>li", "<cmd>Lazy install<cr>", { desc = "Install plugins" })
-- vim.keymap.set("n", "<leader>lu", "<cmd>Lazy update<cr>", { desc = "Update plugins" })
