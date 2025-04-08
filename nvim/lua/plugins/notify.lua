return {
    "rcarriga/nvim-notify",
    opts = {
        -- Optional: Customize notification behavior
        stages = "fade_in_slide_out", -- Animation style (e.g., "fade", "slide", "static")
        timeout = 3000, -- Time in milliseconds before notifications disappear
        background_colour = "#000000", -- Background color for notifications
        level = 2, -- Minimum log level to display (2 = WARN)
    },
    config = function(_, opts)
        -- Load the plugin and apply settings
        local notify = require("notify")
        notify.setup(opts)

        -- Override Neovim's default notification handler
        vim.notify = notify

        -- Optional: Keymap to open the notification history
        vim.keymap.set("n", "<leader>un", function()
            notify.dismiss({ silent = true, pending = true }) -- Clear all notifications
            vim.cmd("Notifications") -- Open the notification history
        end, { desc = "Open Notifications" })
    end,
    keys = {
        { "<leader>un", "<cmd>Notifications<cr>", desc = "Open Notifications" },
    },
    event = "VeryLazy", -- Load the plugin lazily after startup
}
