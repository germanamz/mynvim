-- Autocommands
local pkgmgr = require("pkgmgr")
local utilPath = require("util.path")
local keybind_docs = require("keybind_docs")

-- Auto-format on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    require("conform").format({ bufnr = args.buf })
  end,
})

-- Auto-lint on save and when entering buffer
vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
  callback = function()
    local lint_setup = require("plugins.formatting")
    if lint_setup.set_dynamic_linter then
      lint_setup.set_dynamic_linter()
    end
    require("lint").try_lint()
  end,
})

-- Auto-open nvim-tree on startup
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require("nvim-tree.api").tree.open()
  end
})

-- Title string update
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