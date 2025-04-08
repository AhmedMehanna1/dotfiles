return {
  {
    "theprimeagen/harpoon",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      -- set a vim motion to <shift>m to mark a file with harpoon
      vim.keymap.set(
        "n",
        "<s-m>",
        "<cmd>lua require('plugins.harpoon').mark_file()<cr>",
        { desc = "harpoon mark file" }
      )
      -- set a vim motion to the tab key to open the harpoon menu to easily navigate frequented files
      vim.keymap.set(
        "n",
        "<tab>",
        "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>",
        { desc = "harpoon toggle menu" }
      )
    end,
  },
}
