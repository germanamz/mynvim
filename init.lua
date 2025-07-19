local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git","clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "nvim-lua/plenary.nvim" },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { "williamboman/mason.nvim", config = true },
  { "williamboman/mason-lspconfig.nvim" },
  { "neovim/nvim-lspconfig" },
  { "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip"
    }
  },
  { "stevearc/conform.nvim" },
  { "mfussenegger/nvim-lint" },
  { "mfussenegger/nvim-dap" },
  { "rcarriga/nvim-dap-ui", opts = {} },
  { "nvim-neotest/nvim-nio" },
  { "nvim-lualine/lualine.nvim", opts = { theme = "auto" } },
  { "ckipp01/stylua-nvim" },
  { "nvim-lua/plenary.nvim" },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      { "nvim-telescope/telescope-file-browser.nvim" },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          prompt_prefix = "🔭 ",
          selection_caret = " ",
          mappings = {
            i = { ["<C-k>"] = actions.move_selection_previous,
              ["<C-j>"] = actions.move_selection_next },
          },
          file_ignore_patterns = {
            "node_modules",
            "%.pnpm",
            "%.turbo",
            "dist",
            "build",
            "^cmake%-build%-debug/",
          },
        },
        extensions = {
          file_browser = { hijack_netrw = true },
        },
      })

      pcall(telescope.load_extension, "fzf")
      pcall(telescope.load_extension, "file_browser")
    end,
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",    desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>",  desc = "Help tags" },
      { "<leader>fe", "<cmd>Telescope file_browser<cr>", desc = "File browser" },
    },
  },

  {
    "numToStr/Comment.nvim",
    opts = {},
  }
})

require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "javascript",
    "typescript",
    "tsx",
    "toml",
    "yaml",
    "json",
    "rust",
    "c",
    "cpp",
    "python",
    "zig",
    "lua",
    "vimdoc",
    "go",
    "css",
    "cmake",
    "asm"
  },
  highlight = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<Leader>ss",
      node_incremental = "<Leader>si",
      scope_incremental = "<Leader>sc",
      node_decremental = "<Leader>sd",
    },
  },
  indent = { enable = true },
})

local lsp_list = {
  "ts_ls",
  "eslint",
  "oxlint",
  "rust_analyzer",
  "clangd",
  "pyright",
  "zls",
}

require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = lsp_list,
  automatic_installation = true,
})


-- LSPConfiguration
local pkgmgr = require("pkgmgr") -- A custom script in ./lua folder
local lsp = require("lspconfig")
local util = require("lspconfig.util")
local on_attach = function(_, bufnr)
  local nmap = function(keys, func, desc)
    if desc then desc = "LSP: " .. desc end
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end
  nmap("gd",  vim.lsp.buf.definition, "Go to Definition")
  nmap("K",   vim.lsp.buf.hover, "Hover Docs")
  nmap("<F2>",vim.lsp.buf.rename, "Rename Symbol")
end
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- loop through servers
for _,srv in ipairs(lsp_list) do
  lsp[srv].setup{ on_attach = on_attach, capabilities = capabilities }
end

-- Rust‑specific goodies
lsp.rust_analyzer.setup{
  settings = { ["rust-analyzer"] = { cargo = { allFeatures = true } } }
}

-- TS/JS specific goodies
lsp.ts_ls.setup{
  on_attach = function(client, bufnr)
    pkgmgr.add_package_bin_to_path(vim.api.nvim_buf_get_name(bufnr))

    client.server_capabilities.documentFormattingProvider = false
    on_attach(client, bufnr)
  end,
  capabilities = capabilities,
  root_dir = function(fname)
    return pkgmgr.package_root(fname)
        or pkgmgr.workspace_root(fname)
        or util.find_git_ancestor(fname)
  end,
}

-- eslint goodies
lsp.eslint.setup {
  on_attach = function(client, bufnr)
    pkgmgr.add_package_bin_to_path(vim.api.nvim_buf_get_name(bufnr))
    on_attach(client, bufnr)
  end,
  capabilities = capabilities,
  root_dir = function(fname)
    -- If you have a central ESLint config at workspace root, this will find it.
    -- Otherwise it will stop at the package config.
    return util.root_pattern(
      -- ESLint config files
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
    or pkgmgr.package_root(fname)
    or pkgmgr.workspace_root(fname)
  end,
}

-- Use oxlint if no eslint present
lsp.oxlint.setup {
  on_attach = function(client, bufnr)
    pkgmgr.add_package_bin_to_path(vim.api.nvim_buf_get_name(bufnr))
    on_attach(client, bufnr)
  end,
  capabilities = capabilities,
  root_dir = function(fname)
    -- Skip if ESLint config exists anywhere above.
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
    -- Otherwise pick package root, then workspace.
    return pkgmgr.package_root(fname)
        or pkgmgr.workspace_root(fname)
        or util.find_git_ancestor(fname)
  end,
}

-- lualine goodies
require("lualine").setup({
  sections = {
    lualine_c = {
      {
        -- Root folder component
        function()
          local bufname = vim.api.nvim_buf_get_name(0)
          if bufname == '' then
            return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
          end
            return vim.fn.fnamemodify(pkgmgr.workspace_root(bufname), ":t")
        end,
        icon = "",
        padding = { left = 1, right = 1 },
      },
      {
        "filename",
        path = 1,
      }
    },
  },
})

-- Diagnostic
vim.keymap.set(
  "n",
  "<leader>e",
  vim.diagnostic.open_float,
  { desc = "Diagnostic: show line message" }
)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- nvim-cmp: autocompletion
local cmp = require("cmp")
cmp.setup({
  snippet = {
    expand = function(args) require("luasnip").lsp_expand(args.body) end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"]      = cmp.mapping.confirm({ select = true }),
  }),
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip"  },
    { name = "path"     },
  },
})


-- Formatting and Linting
require("conform").setup({
  notify_on_error = false,
  formatters_by_ft = {
    javascript = { "prettier_or_prettierd", "eslint_d_fix" },
    typescript = { "prettier_or_prettierd", "eslint_d_fix" },
    javascriptreact = { "prettier_or_prettierd", "eslint_d_fix" },
    typescriptreact = { "prettier_or_prettierd", "eslint_d_fix" },
    -- keep your others:
    rust       = { "rustfmt" },
    c          = { "clang_format" },
    cpp        = { "clang_format" },
    python     = { "black", "isort" },
    zig        = { "zigfmt" },
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
-- auto‑format on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args) require("conform").format({ bufnr = args.buf }) end,
})


-- Editor configs
local opt = vim.opt         -- short alias
opt.tabstop     = 2          -- 1 tab == 2 columns
opt.shiftwidth  = 2          -- << and >> shift by 2
opt.softtabstop = 2          -- <Tab>/<BS> count as 2
opt.expandtab   = true       -- use spaces instead of <Tab>
opt.smartindent = true       -- smart auto‑indent
opt.number         = true  -- absolute number on cursor line
-- opt.relativenumber = true  -- relative numbers elsewhere

-- Indent / dedent with Tab in visual mode
vim.keymap.set("v", "<Tab>",   ">gv")
vim.keymap.set("v", "<S-Tab>", "<gv")

-- Whitespaces
vim.opt.list = true
vim.opt.listchars = {
  tab      = '»·',
  trail    = '·',
  extends  = '>',
  precedes = '<',
  nbsp     = '␣',
  space    = '·',
}

-- Title
local utilPath = require("util.path")
vim.o.title = true
vim.api.nvim_create_autocmd({"BufEnter", "DirChanged"}, {
  callback = function()
    local bpath = vim.api.nvim_buf_get_name(0)
    local wpath = pkgmgr.workspace_root(bpath)

    if wpath == nil then
      wpath = vim.fn.getcwd()
    end

    vim.o.titlestring = string.format(
      "Nvim: %s - %s",
      vim.fn.fnamemodify(wpath, ":t"),
      utilPath.relative(bpath, wpath)
    )
  end,
})
