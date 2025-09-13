local M = {}

-- Smart Code Action dispatcher based on filetype/project
function M.run()
  local ft = vim.bo.filetype

  -- C# via OmniSharp (if available)
  if ft == "cs" and vim.fn.exists(":OmniSharpCodeActions") == 2 then
    vim.cmd("OmniSharpCodeActions")
    return
  end

  -- Rust via rust-tools (if available)
  if ft == "rust" then
    local ok, rt = pcall(require, "rust-tools")
    if ok and rt.code_action_group and rt.code_action_group.code_action_group then
      rt.code_action_group.code_action_group()
      return
    end
  end

  -- Fallback to LSP code actions for all other languages
  vim.lsp.buf.code_action()
end

-- Organize Imports: language-aware, with LSP fallback
function M.organize()
  local ft = vim.bo.filetype

  -- Java: prefer jdtls API when available
  if ft == "java" then
    local ok, jdtls = pcall(require, "jdtls")
    if ok and jdtls.organize_imports then
      jdtls.organize_imports()
      return
    end
  end

  -- TypeScript/JavaScript: try typescript.nvim actions if present
  if ft == "typescript" or ft == "typescriptreact" or ft == "javascript" or ft == "javascriptreact" then
    local ok_ts, ts = pcall(require, "typescript")
    if ok_ts and ts.actions and type(ts.actions.organizeImports) == "function" then
      local ok = pcall(ts.actions.organizeImports)
      if ok then return end
    end
  end

  -- Generic LSP code action (apply automatically if supported)
  local ok = pcall(vim.lsp.buf.code_action, {
    apply = true,
    context = { only = { "source.organizeImports" }, diagnostics = {} },
  })
  if not ok then
    -- Fallback: open code actions picker filtered to organize imports
    vim.lsp.buf.code_action({
      context = { only = { "source.organizeImports" }, diagnostics = {} },
    })
  end
end

return M
