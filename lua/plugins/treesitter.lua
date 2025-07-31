-- Treesitter configuration
local M = {}

local keybind_docs = require("keybind_docs")

function M.setup()
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

  -- Setup rainbow delimiters
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
end

return M