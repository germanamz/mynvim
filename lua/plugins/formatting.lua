-- Formatting and linting configuration
local M = {}

local pkgmgr = require("pkgmgr")

function M.setup()
  -- Setup conform.nvim for formatting
  require("conform").setup({
    notify_on_error = false,
    formatters_by_ft = {
      javascript = { "prettier_or_prettierd" },
      typescript = { "prettier_or_prettierd" },
      javascriptreact = { "prettier_or_prettierd" },
      typescriptreact = { "prettier_or_prettierd" },
      rust = { "rustfmt" },
      c = { "clang_format" },
      cpp = { "clang_format" },
      python = { "black", "isort" },
      zig = { "zigfmt" },
      prisma = { "prisma" },
    },
    formatters = {
      prettier_or_prettierd = {
        command = function(ctx)
          -- try prettierd, then prettier
          local p = pkgmgr.prefer_local("prettierd", ctx.filename)
          if vim.fn.executable(p) == 1 then return p end
          return pkgmgr.prefer_local("prettier", ctx.filename)
        end,
        args = { "--stdin-filepath", "$FILENAME" },
        stdin = true,
      },
      eslint_d_fix = {
        command = function(ctx)
          return pkgmgr.prefer_local("eslint_d", ctx.filename)
        end,
        args = { "--fix-to-stdout", "--stdin", "--stdin-filename", "$FILENAME" },
        stdin = true,
        exit_codes = { 0, 1 }, -- ESLint returns 1 when it finds problems
      },
    },
  })

  -- Setup nvim-lint
  local lint = require("lint")
  
  -- Set default linters (will be overridden dynamically)  
  lint.linters_by_ft = {
    javascript = { "oxlint" },
    typescript = { "oxlint" },
    javascriptreact = { "oxlint" },
    typescriptreact = { "oxlint" },
  }
end

-- Helper function to dynamically set linter
function M.set_dynamic_linter()
  local filename = vim.api.nvim_buf_get_name(0)
  local filetype = vim.bo.filetype
  local util = require("lspconfig.util")
  local lint = require("lint")
  
  -- Only handle JS/TS files
  if not vim.tbl_contains({"javascript", "typescript", "javascriptreact", "typescriptreact"}, filetype) then
    return
  end
  
  local selected_linters = {}
  
  -- Check if ESLint config exists AND eslint_d is available
  if util.root_pattern(
    ".eslintrc", ".eslintrc.js", ".eslintrc.cjs", ".eslintrc.json",
    ".eslintrc.yaml", ".eslintrc.yml", "eslint.config.js",
    "eslint.config.mjs", "eslint.config.cjs", "eslint.config.ts",
    "eslint.config.mts", "eslint.config.cts"
  )(filename) then
    local eslint_cmd = pkgmgr.prefer_local("eslint_d", filename)
    if vim.fn.executable(eslint_cmd) == 1 then
      selected_linters = { "eslint_d" }
    end
  end
  
  -- Use oxlint as fallback if available and no eslint
  if #selected_linters == 0 then
    local oxlint_cmd = pkgmgr.prefer_local("oxlint", filename)
    if vim.fn.executable(oxlint_cmd) == 1 then
      selected_linters = { "oxlint" }
    end
  end
  
  -- Update the linter for this filetype
  lint.linters_by_ft[filetype] = selected_linters
end

return M