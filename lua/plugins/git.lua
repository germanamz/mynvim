-- Git-related plugin configurations
local M = {}

local keybind_docs = require("keybind_docs")

function M.setup_gitsigns()
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

return M