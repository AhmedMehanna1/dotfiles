return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    init = function()
        vim.g.lualine_laststatus = vim.o.laststatus
        if vim.fn.argc(-1) > 0 then
            vim.o.statusline = " "
        else
            vim.o.laststatus = 0
        end
    end,
    opts = function()
        local icons = require("utils.icons")

        vim.o.laststatus = vim.g.lualine_laststatus

        return {
            options = {
                theme = "auto",
                globalstatus = true,
                disabled_filetypes = { statusline = { "dashboard", "alpha", "starter" } },
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch" },
                lualine_c = {
                    {
                        "diagnostics",
                        symbols = {
                            error = icons.diagnostics.Error,
                            warn = icons.diagnostics.Warn,
                            info = icons.diagnostics.Info,
                            hint = icons.diagnostics.Hint,
                        },
                    },
                    { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
                    { "filename", path = 1, symbols = { modified = "  ", readonly = "", unnamed = "" } },
                },
                lualine_x = {
                    {
                        function()
                            local ok, noice = pcall(require, "noice")
                            return ok and noice.api.status.command.get() or ""
                        end,
                        cond = function()
                            local ok, noice = pcall(require, "noice")
                            return ok and noice.api.status.command.has()
                        end,
                        color = function()
                            return require("utils").fg("Statement")
                        end,
                    },
                    {
                        function()
                            local ok, noice = pcall(require, "noice")
                            return ok and noice.api.status.mode.get() or ""
                        end,
                        cond = function()
                            local ok, noice = pcall(require, "noice")
                            return ok and noice.api.status.mode.has()
                        end,
                        color = function()
                            return require("utils").fg("Constant")
                        end,
                    },
                    {
                        function()
                            local ok, dap = pcall(require, "dap")
                            return ok and ("  " .. dap.status()) or ""
                        end,
                        cond = function()
                            local ok, dap = pcall(require, "dap")
                            return ok and dap.status() ~= ""
                        end,
                        color = function()
                            return require("utils").fg("Debug")
                        end,
                    },
                    {
                        function()
                            local ok, lazy = pcall(require, "lazy.status")
                            return ok and lazy.updates() or ""
                        end,
                        cond = function()
                            local ok, lazy = pcall(require, "lazy.status")
                            return ok and lazy.has_updates()
                        end,
                        color = function()
                            return require("utils").fg("Special")
                        end,
                    },
                },
                lualine_y = {
                    { "progress", separator = " ", padding = { left = 1, right = 0 } },
                    { "location", padding = { left = 0, right = 1 } },
                },
                lualine_z = {
                    function()
                        return " " .. os.date("%R")
                    end,
                },
            },
            extensions = { "neo-tree", "lazy" },
        }
    end,
}
