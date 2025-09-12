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
    formatters = {
      injected = { options = { ignore_errors = true } },

      -- Java formatter
      ["google-java-format"] = {
        prepend_args = { "--aosp" }, -- optional: 4 spaces, 100 line length
      },

      -- JS/TS/JSON formatter overrides
      prettierd = {
        prepend_args = { "--tab-width", "4" },
      },
      prettier = {
        prepend_args = { "--tab-width", "4" },
      },

      -- Rustfmt (respects rustfmt.toml if present)
      rustfmt = {
        prepend_args = { "--edition", "2021" },
      },
    },
  },
}
