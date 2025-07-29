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

local keybind_docs = require("keybind_docs")

require("lazy").setup({
  { "nvim-lua/plenary.nvim" },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { "nvim-treesitter/nvim-treesitter-textobjects" },
  { "HiPhish/rainbow-delimiters.nvim" },
  { "projekt0n/github-nvim-theme", priority = 1000 },
  { 
    "lewis6991/gitsigns.nvim", 
    config = function()
      require('gitsigns').setup({
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          
          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end
          
          -- Navigation
          map('n', ']g', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, {expr=true, desc = 'Next git hunk'})
          
          map('n', '[g', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, {expr=true, desc = 'Previous git hunk'})
          
          -- Actions
          map('n', '<leader>gp', gs.preview_hunk, { desc = 'Preview git hunk' })
          map('n', '<leader>gd', gs.diffthis, { desc = 'Diff this buffer' })
          
          -- Document these keybindings
          keybind_docs.document_keymap('n', ']g', 'Next git hunk', 'Git Signs')
          keybind_docs.document_keymap('n', '[g', 'Previous git hunk', 'Git Signs')
          keybind_docs.document_keymap('n', '<leader>gp', 'Preview git hunk', 'Git Signs')
          keybind_docs.document_keymap('n', '<leader>gd', 'Diff this buffer', 'Git Signs')
        end
      })
    end
  },
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
          -- file_ignore_patterns = {
          --   "node_modules",
          --   "%.pnpm",
          --   "%.turbo",
          --   "dist",
          --   "build",
          --   "^cmake%-build%-debug/",
          -- },
        },
        extensions = {
          file_browser = { hijack_netrw = true },
        },
      })

      pcall(telescope.load_extension, "fzf")
      pcall(telescope.load_extension, "file_browser")
    end,
    keys = {
      {
        "<leader>ff",
        function()
          require("telescope.builtin").find_files({
            find_command = { "sh", "-c", "git ls-files --exclude-standard --others --cached; find . -name '.env*' -type f" },
            follow = true,
            hidden = true,
          })
        end,
        desc = "Find git files (tracked + untracked)",
      },
      {
        "<leader>ft",
        function() require("telescope.builtin").git_files() end,
        desc = "Find git files (tracked only)",
      },
      -- { "<leader>ff", "<cmd>Telescope git_files<cr>", desc = "Find only git files" },
      { "<leader>fa", "<cmd>Telescope find_files<cr>", desc = "Find all files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",    desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>",  desc = "Help tags" },
      { "<leader>fe", "<cmd>Telescope file_browser<cr>", desc = "File browser" },
      { 
        "<leader>fE", 
        function() 
          require("telescope").extensions.file_browser.file_browser({
            path = vim.fn.expand('%:p:h'),
            cwd = vim.fn.getcwd(),
            respect_gitignore = false,
          })
        end, 
        desc = "File browser (current buffer dir)" 
      },
    },
    init = function()
      -- Document Telescope keybindings
      keybind_docs.document_keymap('n', '<leader>ff', 'Find git files (tracked + untracked + .env files)', 'Telescope')
      keybind_docs.document_keymap('n', '<leader>ft', 'Find git files (tracked only)', 'Telescope')
      keybind_docs.document_keymap('n', '<leader>fa', 'Find all files', 'Telescope')
      keybind_docs.document_keymap('n', '<leader>fg', 'Live grep', 'Telescope')
      keybind_docs.document_keymap('n', '<leader>fb', 'Buffers', 'Telescope')
      keybind_docs.document_keymap('n', '<leader>fh', 'Help tags', 'Telescope')
      keybind_docs.document_keymap('n', '<leader>fe', 'File browser', 'Telescope')
      keybind_docs.document_keymap('n', '<leader>fE', 'File browser (current buffer directory)', 'Telescope')
      keybind_docs.document_keymap('i', '<C-k>', 'Move selection up', 'Telescope Internal Mappings')
      keybind_docs.document_keymap('i', '<C-j>', 'Move selection down', 'Telescope Internal Mappings')
    end,
  },

  {
    "numToStr/Comment.nvim",
    opts = {},
  },
  { "hrsh7th/cmp-buffer" },
  { "folke/neodev.nvim", opts = {} },
})

vim.cmd.colorscheme("github_light")

-- Fix whitespace colors for github theme
vim.api.nvim_set_hl(0, "Whitespace", { fg = "#d1d9e0" })
vim.api.nvim_set_hl(0, "NonText", { fg = "#d1d9e0" })

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
    "asm",
    "markdown",
    "markdown_inline",
    "html",
    "dockerfile",
    "bash",
    "regex",
    "prisma"
  },
  highlight = { 
    enable = true,
    additional_vim_regex_highlighting = false,
  },
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
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
      },
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {
        ["]f"] = "@function.outer",
        ["]c"] = "@class.outer",
      },
      goto_next_end = {
        ["]F"] = "@function.outer",
        ["]C"] = "@class.outer",
      },
      goto_previous_start = {
        ["[f"] = "@function.outer",
        ["[c"] = "@class.outer",
      },
      goto_previous_end = {
        ["[F"] = "@function.outer",
        ["[C"] = "@class.outer",
      },
    },
  },
})

-- Document treesitter text object keybindings
keybind_docs.document_keymap('x', 'af', 'Select function (outer)', 'Treesitter Text Objects')
keybind_docs.document_keymap('x', 'if', 'Select function (inner)', 'Treesitter Text Objects')
keybind_docs.document_keymap('x', 'ac', 'Select class (outer)', 'Treesitter Text Objects')
keybind_docs.document_keymap('x', 'ic', 'Select class (inner)', 'Treesitter Text Objects')
keybind_docs.document_keymap('x', 'aa', 'Select parameter (outer)', 'Treesitter Text Objects')
keybind_docs.document_keymap('x', 'ia', 'Select parameter (inner)', 'Treesitter Text Objects')
keybind_docs.document_keymap('n', ']f', 'Go to next function start', 'Treesitter Text Objects')
keybind_docs.document_keymap('n', ']c', 'Go to next class start', 'Treesitter Text Objects')
keybind_docs.document_keymap('n', ']F', 'Go to next function end', 'Treesitter Text Objects')
keybind_docs.document_keymap('n', ']C', 'Go to next class end', 'Treesitter Text Objects')
keybind_docs.document_keymap('n', '[f', 'Go to previous function start', 'Treesitter Text Objects')
keybind_docs.document_keymap('n', '[c', 'Go to previous class start', 'Treesitter Text Objects')
keybind_docs.document_keymap('n', '[F', 'Go to previous function end', 'Treesitter Text Objects')
keybind_docs.document_keymap('n', '[C', 'Go to previous class end', 'Treesitter Text Objects')
keybind_docs.document_keymap('n', '<Leader>ss', 'Initialize selection', 'Treesitter Text Objects')
keybind_docs.document_keymap('n', '<Leader>si', 'Increment node selection', 'Treesitter Text Objects')
keybind_docs.document_keymap('n', '<Leader>sc', 'Increment scope selection', 'Treesitter Text Objects')
keybind_docs.document_keymap('n', '<Leader>sd', 'Decrement node selection', 'Treesitter Text Objects')

local rainbow_delimiters = require("rainbow-delimiters")
vim.g.rainbow_delimiters = {
  strategy = {
    [''] = rainbow_delimiters.strategy['global'],
    vim = rainbow_delimiters.strategy['local'],
  },
  query = {
    [''] = 'rainbow-delimiters',
    lua = 'rainbow-blocks',
  },
  highlight = {
    'RainbowDelimiterRed',
    'RainbowDelimiterYellow',
    'RainbowDelimiterBlue',
    'RainbowDelimiterOrange',
    'RainbowDelimiterGreen',
    'RainbowDelimiterViolet',
    'RainbowDelimiterCyan',
  },
}

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

require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = lsp_list,
  automatic_installation = true,
})


-- LSPConfiguration
local pkgmgr = require("pkgmgr") -- A custom script in ./lua folder
local lsp = require("lspconfig")
local util = require("lspconfig.util")
local cwd_root = pkgmgr.cwd_root()
local on_attach = function(client, bufnr)
  local nmap = function(keys, func, desc)
    if desc then desc = "LSP: " .. desc end
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end
  nmap("gd",  vim.lsp.buf.definition, "Go to Definition")
  nmap("K",   vim.lsp.buf.hover, "Hover Docs")
  nmap("<F2>",vim.lsp.buf.rename, "Rename Symbol")
  
  -- Document LSP keybindings
  keybind_docs.document_keymap('n', 'gd', 'Go to definition', 'LSP')
  keybind_docs.document_keymap('n', 'K', 'Hover documentation', 'LSP')
  keybind_docs.document_keymap('n', '<F2>', 'Rename symbol', 'LSP')
  
  if client.server_capabilities.semanticTokensProvider then
    vim.lsp.semantic_tokens.start(bufnr, client.id)
  end
end
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- loop through servers
for _,srv in ipairs(lsp_list) do
  lsp[srv].setup{
    on_attach = on_attach,
    capabilities = capabilities,
    root_dir = cwd_root
  }
end

-- Lua-specific goodies
require("neodev").setup({})
lsp.lua_ls.setup{
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
}


-- Rust‑specific goodies
lsp.rust_analyzer.setup{
  settings = { ["rust-analyzer"] = { cargo = { allFeatures = true } } }
}

-- Python-specific goodies
lsp.pyright.setup{
  on_attach = on_attach,
  capabilities = capabilities,
  root_dir = cwd_root,
  settings = {
    python = {
      analysis = {
        diagnosticMode = "workspace",
        autoImportCompletions = true,
        -- extraPaths = { vim.fn.getcwd() .. "/src" }, -- add if you keep code in src/
      },
    },
  },
}


-- TS/JS specific goodies
lsp.ts_ls.setup{
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
}

-- eslint goodies - only setup if ESLint is available
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

lsp.eslint.setup {
  on_attach = function(client, bufnr)
    pkgmgr.add_package_bin_to_path(vim.api.nvim_buf_get_name(bufnr))
    on_attach(client, bufnr)
  end,
  capabilities = capabilities,
  root_dir = setup_eslint_if_available(),
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
    return pkgmgr.cwd_root()
  end,
}

-- lualine goodies
require("lualine").setup({
  sections = {
    lualine_c = {
      {
        pkgmgr.cwd_root(),
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

-- Document diagnostic keybindings
keybind_docs.document_keymap('n', '<leader>e', 'Show diagnostic message for current line', 'Diagnostics')
keybind_docs.document_keymap('n', '[d', 'Previous diagnostic', 'Diagnostics')
keybind_docs.document_keymap('n', ']d', 'Next diagnostic', 'Diagnostics')

-- nvim-cmp: autocompletion
local cmp = require("cmp")

vim.opt.completeopt = { "menu", "menuone", "noselect" }

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
    {
      name = "buffer",
      option = {
        get_bufnrs = function() return vim.api.nvim_list_bufs() end
      }
    },
    { name = "path"     },
    { name = "luasnip"  },
  },
})

-- Document completion keybindings
keybind_docs.document_keymap('i', '<C-Space>', 'Trigger completion', 'Completion')
keybind_docs.document_keymap('i', '<CR>', 'Confirm completion', 'Completion')

-- Helper function to detect linting setup
local function get_js_linter(filename)
  local util = require("lspconfig.util")
  
  -- Check if ESLint config exists AND eslint is available
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
  )(filename) then
    -- Only use eslint if it's actually available
    local eslint_cmd = pkgmgr.prefer_local("eslint_d", filename)
    if vim.fn.executable(eslint_cmd) == 1 then
      return "eslint_d_fix"
    end
  end
  
  -- Use oxlint as fallback (check if available)
  local oxlint_cmd = pkgmgr.prefer_local("oxlint", filename)
  if vim.fn.executable(oxlint_cmd) == 1 then
    return "oxlint_fix"
  end
  
  -- Default to no linting fix
  return nil
end

-- Formatting and Linting
require("conform").setup({
  notify_on_error = false,
  formatters_by_ft = {
    javascript = function(bufnr)
      local filename = vim.api.nvim_buf_get_name(bufnr)
      local linter = get_js_linter(filename)
      return linter and { "prettier_or_prettierd", linter } or { "prettier_or_prettierd" }
    end,
    typescript = function(bufnr)
      local filename = vim.api.nvim_buf_get_name(bufnr)
      local linter = get_js_linter(filename)
      return linter and { "prettier_or_prettierd", linter } or { "prettier_or_prettierd" }
    end,
    javascriptreact = function(bufnr)
      local filename = vim.api.nvim_buf_get_name(bufnr)
      local linter = get_js_linter(filename)
      return linter and { "prettier_or_prettierd", linter } or { "prettier_or_prettierd" }
    end,
    typescriptreact = function(bufnr)
      local filename = vim.api.nvim_buf_get_name(bufnr)
      local linter = get_js_linter(filename)
      return linter and { "prettier_or_prettierd", linter } or { "prettier_or_prettierd" }
    end,
    -- keep your others:
    rust       = { "rustfmt" },
    c          = { "clang_format" },
    cpp        = { "clang_format" },
    python     = { "black", "isort" },
    zig        = { "zigfmt" },
    prisma     = { "prisma" },
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
    oxlint_fix = {
      command = function(ctx)
        return pkgmgr.prefer_local("oxlint", ctx.filename)
      end,
      args = { "--fix", "--stdin-filename", "$FILENAME" },
      stdin = true,
      exit_codes = { 0, 1 },
    },
  },
})
-- Setup nvim-lint with dynamic linter assignment
local lint = require("lint")

-- Set default linters (will be overridden dynamically)  
lint.linters_by_ft = {
  javascript = { "oxlint" },
  typescript = { "oxlint" },
  javascriptreact = { "oxlint" },
  typescriptreact = { "oxlint" },
}

-- Helper function to dynamically set linter
local function set_dynamic_linter()
  local filename = vim.api.nvim_buf_get_name(0)
  local filetype = vim.bo.filetype
  local util = require("lspconfig.util")
  
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

-- Auto-lint on save and when entering buffer
vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
  callback = function()
    set_dynamic_linter()
    require("lint").try_lint()
  end,
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

-- Document visual mode keybindings
keybind_docs.document_keymap('v', '<Tab>', 'Indent selection', 'Visual Mode')
keybind_docs.document_keymap('v', '<S-Tab>', 'Dedent selection', 'Visual Mode')

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
    local wpath = pkgmgr.cwd_root()

    vim.o.titlestring = string.format(
      "Nvim: %s - %s",
      vim.fn.fnamemodify(wpath, ":t"),
      utilPath.relative(bpath, wpath)
    )
  end,
})

-- Generate help tags for custom documentation
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    keybind_docs.generate_keybinding_docs()
    local doc_path = vim.fn.stdpath("config") .. "/doc"
    if vim.fn.isdirectory(doc_path) == 1 then
      vim.cmd("helptags " .. doc_path)
    end
  end,
})
