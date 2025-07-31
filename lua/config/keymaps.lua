-- Global keymaps
local keybind_docs = require("keybind_docs")

-- Visual mode indentation
vim.keymap.set("v", "<Tab>", ">gv")
vim.keymap.set("v", "<S-Tab>", "<gv")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Diagnostic: show line message" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- Document keybindings
keybind_docs.document_keymap('v', '<Tab>', 'Indent selection', 'Visual Mode')
keybind_docs.document_keymap('v', '<S-Tab>', 'Dedent selection', 'Visual Mode')
keybind_docs.document_keymap('n', '<leader>e', 'Show diagnostic message for current line', 'Diagnostics')
keybind_docs.document_keymap('n', '[d', 'Previous diagnostic', 'Diagnostics')
keybind_docs.document_keymap('n', ']d', 'Next diagnostic', 'Diagnostics')