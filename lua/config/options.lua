-- Editor configuration options
local opt = vim.opt

-- Indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.smartindent = true

-- Line numbers
opt.number = true
-- opt.relativenumber = true  -- uncomment if you want relative numbers

-- File handling
opt.fixendofline = true

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }

-- Whitespace visualization
opt.list = true
opt.listchars = {
  tab = '»·',
  trail = '·',
  extends = '>',
  precedes = '<',
  nbsp = '␣',
  space = '·',
}

-- Title configuration
opt.title = true

-- Tabline configuration
opt.showtabline = 2