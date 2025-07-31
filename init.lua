-- Load all configurations
require("config")
require("plugins")
require("core")

-- Initialize plugins and their configurations
require("plugins.lsp").setup()
require("plugins.completion").setup()
require("plugins.formatting").setup()
require("plugins.treesitter").setup()
require("plugins.ui").setup_lualine()