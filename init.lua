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

  -- 1️⃣  Treesitter (fast, accurate syntax & text‑objects)
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- 2️⃣  LSP + server installer
  { "williamboman/mason.nvim",          config = true },
  { "williamboman/mason-lspconfig.nvim" },
  { "neovim/nvim-lspconfig" },

  -- 3️⃣  Completion engine
  { "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip"
    }
  },

  -- 4️⃣  Formatting / linting
  { "stevearc/conform.nvim" },      -- simple formatter bridge
  { "mfussenegger/nvim-lint" },     -- lightweight linter bridge

  -- 5️⃣  (Optional) Debug Adapter Protocol
  { "mfussenegger/nvim-dap" },
  { "rcarriga/nvim-dap-ui", opts = {} },

  { "nvim-neotest/nvim-nio" },

  { "nvim-lualine/lualine.nvim", opts = { theme = "auto" } },
  { "nvim-telescope/telescope.nvim" },
  { "ckipp01/stylua-nvim" },
  { "nvim-lua/plenary.nvim" },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {           -- optional but common extras
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      { "nvim-telescope/telescope-file-browser.nvim" },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          prompt_prefix = "🔭 ",
          selection_caret = " ", -- nerd-font icon
          mappings = {            -- a couple of handy defaults
            i = { ["<C-k>"] = actions.move_selection_previous,
              ["<C-j>"] = actions.move_selection_next },
          },
        },
        extensions = {
          file_browser = { hijack_netrw = true },
        },
      })

      -- Optional: load extensions only if they’re present
      pcall(telescope.load_extension, "fzf")
      pcall(telescope.load_extension, "file_browser")
    end,
    keys = {                     -- lazy.nvim “lazy‑load” on these mappings
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",    desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>",  desc = "Help tags" },
      { "<leader>fe", "<cmd>Telescope file_browser<cr>", desc = "File browser" },
    },
  },
})

require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "javascript",
    "typescript",
    "rust",
    "c",
    "cpp",
    "python",
    "zig",
    "lua",
    "vimdoc"
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
lsp.ts_ls.setup {
  on_attach = function(client, bufnr)
    -- Disable lsp formatting in favor of linters
    client.server_capabilities.documentFormattingProvider = false
    on_attach(client, bufnr)
  end,
}

-- If eslint present, use eslint
lsp.eslint.setup{
  root_dir = function(fname)
    return util.root_pattern(
      ".eslintrc*", "eslint.config.*"
    )(fname)
  end,
  on_attach = on_attach,
  capabilities = capabilities,
}

-- Use oxlint if no eslint present
lsp.oxlint.setup{
  root_dir = function(fname)
    -- If we find any ESLint config in the tree, bail out – ESLint will handle it
    if util.root_pattern(".eslintrc*", "eslint.config.*")(fname) then
      return nil
    end
    -- Otherwise use the first folder with package.json / git / oxlint config as root
    return util.root_pattern(".oxlintrc.json", ".git", "package.json")(fname)
  end,
  on_attach = on_attach,
  capabilities = capabilities,
}

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
  formatters_by_ft = {
    javascript = { "prettierd", "eslint_d" },
    typescript = { "prettierd", "eslint_d" },
    rust       = { "rustfmt" },
    c          = { "clang_format" },
    cpp        = { "clang_format" },
    python     = { "black", "isort" },
    zig        = { "zigfmt" },
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
opt.relativenumber = true  -- relative numbers elsewhere

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

