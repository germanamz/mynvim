-- LSP configuration
local M = {}

local keybind_docs = require("keybind_docs")
local pkgmgr = require("pkgmgr")
local lsp = require("lspconfig")
local util = require("lspconfig.util")

local lsp_list = {
  "lua_ls",
  "ts_ls",
  "eslint",
  "oxlint",
  "rust_analyzer",
  "clangd",
  "pyright",
  "zls",
}

local cwd_root = pkgmgr.cwd_root()

local function on_attach(client, bufnr)
  local nmap = function(keys, func, desc)
    if desc then desc = "LSP: " .. desc end
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end
  
  nmap("gd", vim.lsp.buf.definition, "Go to Definition")
  nmap("gD", vim.lsp.buf.declaration, "Go to Declaration")
  nmap("gi", vim.lsp.buf.implementation, "Go to Implementation")
  nmap("gr", vim.lsp.buf.references, "Go to References")
  nmap("K", vim.lsp.buf.hover, "Hover Docs")
  nmap("<F2>", vim.lsp.buf.rename, "Rename Symbol")
  
  -- Document LSP keybindings
  keybind_docs.document_keymap('n', 'gd', 'Go to definition', 'LSP')
  keybind_docs.document_keymap('n', 'gD', 'Go to declaration', 'LSP')
  keybind_docs.document_keymap('n', 'gi', 'Go to implementation', 'LSP')
  keybind_docs.document_keymap('n', 'gr', 'Go to references', 'LSP')
  keybind_docs.document_keymap('n', 'K', 'Hover documentation', 'LSP')
  keybind_docs.document_keymap('n', '<F2>', 'Rename symbol', 'LSP')
  
  if client.server_capabilities.semanticTokensProvider then
    vim.lsp.semantic_tokens.start(bufnr, client.id)
  end
end

local function setup_eslint_if_available()
  return function(fname) 
    -- Check if ESLint config exists
    local eslint_root = util.root_pattern(
      ".eslintrc",
      ".eslintrc.js",
      ".eslintrc.cjs",
      ".eslintrc.json",
      ".eslintrc.yaml",
      ".eslintrc.yml",
      "eslint.config.js",
      "eslint.config.mjs",
      "eslint.config.cjs",
      "eslint.config.ts",
      "eslint.config.mts",
      "eslint.config.cts"
    )(fname)
    
    if not eslint_root then
      return nil
    end
    
    -- Check if ESLint is actually available
    pkgmgr.add_package_bin_to_path(fname)
    local eslint_cmd = pkgmgr.prefer_local("eslint", fname)
    if vim.fn.executable(eslint_cmd) == 0 then
      return nil
    end
    
    return eslint_root
  end
end

function M.setup()
  require("mason").setup()
  require("mason-lspconfig").setup({
    ensure_installed = lsp_list,
    automatic_installation = true,
  })

  local capabilities = require("cmp_nvim_lsp").default_capabilities()
  
  -- Setup basic servers
  for _, srv in ipairs(lsp_list) do
    lsp[srv].setup({
      on_attach = on_attach,
      capabilities = capabilities,
      root_dir = cwd_root
    })
  end

  -- Lua-specific configuration
  require("neodev").setup({})
  lsp.lua_ls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    root_dir = cwd_root,
    settings = {
      Lua = {
        workspace = {
          checkThirdParty = false,
          library = vim.api.nvim_get_runtime_file("", true),
        },
        completion = { callSnippet = "Replace" },
      },
    },
  })

  -- Rust-specific configuration
  lsp.rust_analyzer.setup({
    settings = { ["rust-analyzer"] = { cargo = { allFeatures = true } } }
  })

  -- Python-specific configuration
  lsp.pyright.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    root_dir = cwd_root,
    settings = {
      python = {
        analysis = {
          diagnosticMode = "workspace",
          autoImportCompletions = true,
        },
      },
    },
  })

  -- TypeScript/JavaScript configuration
  lsp.ts_ls.setup({
    on_attach = function(client, bufnr)
      pkgmgr.add_package_bin_to_path(vim.api.nvim_buf_get_name(bufnr))
      client.server_capabilities.documentFormattingProvider = false
      on_attach(client, bufnr)
    end,
    capabilities = capabilities,
    root_dir = cwd_root,
    settings = {
      typescript = { preferences = { includeCompletionsForModuleExports = true } },
      javascript = { preferences = { includeCompletionsForModuleExports = true } },
    }
  })

  -- ESLint configuration with availability check
  lsp.eslint.setup({
    on_attach = function(client, bufnr)
      pkgmgr.add_package_bin_to_path(vim.api.nvim_buf_get_name(bufnr))
      on_attach(client, bufnr)
    end,
    capabilities = capabilities,
    root_dir = setup_eslint_if_available(),
  })

  -- Oxlint as fallback when no ESLint
  lsp.oxlint.setup({
    on_attach = function(client, bufnr)
      pkgmgr.add_package_bin_to_path(vim.api.nvim_buf_get_name(bufnr))
      on_attach(client, bufnr)
    end,
    capabilities = capabilities,
    root_dir = function(fname)
      -- Skip if ESLint config exists anywhere above
      if util.root_pattern(
        ".eslintrc",
        ".eslintrc.js",
        ".eslintrc.cjs",
        ".eslintrc.json",
        ".eslintrc.yaml",
        ".eslintrc.yml",
        "eslint.config.js",
        "eslint.config.mjs",
        "eslint.config.cjs",
        "eslint.config.ts",
        "eslint.config.mts",
        "eslint.config.cts"
      )(fname) then
        return nil
      end
      return pkgmgr.cwd_root()
    end,
  })
end

return M