-- Custom tabline configuration
local M = {}

-- Custom tabline function to show buffers as tabs
function _G.custom_tabline()
  local tabline = ''
  local current_buf = vim.api.nvim_get_current_buf()
  
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_option(buf, 'buflisted') then
      local bufname = vim.api.nvim_buf_get_name(buf)
      local buftype = vim.api.nvim_buf_get_option(buf, 'buftype')
      
      -- Skip special buffers
      if buftype == '' and bufname ~= '' and not bufname:match('NvimTree') then
        local filename = vim.fn.fnamemodify(bufname, ':t')
        if filename == '' then filename = '[No Name]' end
        
        -- Add modified indicator
        local modified = vim.api.nvim_buf_get_option(buf, 'modified') and '*' or ''
        
        -- Highlight current buffer
        local highlight = (buf == current_buf) and '%#TabLineSel#' or '%#TabLine#'
        
        tabline = tabline .. highlight .. ' ' .. buf .. ':' .. filename .. modified .. ' %#TabLine#|'
      end
    end
  end
  
  return tabline .. '%#TabLineFill#'
end

function M.setup()
  vim.opt.tabline = '%!v:lua.custom_tabline()'
end

return M