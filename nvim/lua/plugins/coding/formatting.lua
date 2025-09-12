return {
  "stevearc/conform.nvim",
  dependencies = { "mason.nvim" },
  lazy = true,
  cmd = "ConformInfo",
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ timeout_ms = 3000, lsp_fallback = true })
      end,
      mode = { "n", "v" },
      desc = "Format Document",
    },
  },
  init = function()
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "isort", "black" },
      rust = { "rustfmt" },
      java = { "google-java-format" },
      javascript = { { "prettierd", "prettier" } },
      typescript = { { "prettierd", "prettier" } },
      json = { { "prettierd", "prettier" } },
      go = { "goimports", "gofmt" },
    },
    -- Remove format_on_save - we'll handle it in ftplugin
    formatters = {
      injected = { options = { ignore_errors = true } },
    },
  },
}
