-- Custom tabline configuration
local M = {}
local buffer_util = require('util.buffer')

-- Custom tabline function to show buffers as tabs
function _G.custom_tabline()
  local tabline = ''
  local current_buf = vim.api.nvim_get_current_buf()
  local valid_buffers = buffer_util.get_valid_buffers()
  
  -- Count filename occurrences for duplicate handling
  local count_by_filename = {}
  for _, buf in ipairs(valid_buffers) do
    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':t')
    count_by_filename[filename] = (count_by_filename[filename] or 0) + 1
  end

  -- Build tabline directly from valid buffers
  for _, buf in ipairs(valid_buffers) do
    local bufname = vim.api.nvim_buf_get_name(buf)
    local filename = vim.fn.fnamemodify(bufname, ':t')
    local modified = vim.api.nvim_buf_get_option(buf, 'modified') and '*' or ''

    -- Highlight current buffer
    tabline = tabline .. (buf == current_buf and '%#TabLineSel#' or '%#TabLine#')
    
    -- Add buffer number and name
    tabline = tabline .. ' ' .. buf .. ':'
    
    -- Use relative path for duplicate filenames
    if count_by_filename[filename] > 1 then
      tabline = tabline .. vim.fn.fnamemodify(bufname, ':.')
    else
      tabline = tabline .. filename
    end
    
    tabline = tabline .. modified .. ' %#TabLine#|'
  end

  return tabline .. '%#TabLineFill#'
end

function M.setup()
  vim.opt.tabline = '%!v:lua.custom_tabline()'

  -- Only redraw when buffer display actually changes
  vim.api.nvim_create_autocmd({"BufEnter", "BufDelete", "BufWipeout"}, {
    group = vim.api.nvim_create_augroup("RedrawTabline", { clear = true }),
    callback = function(event)
      -- Only redraw for buffers that would appear in tabline
      if buffer_util.is_valid_buffer(event.buf) then
        vim.schedule(function()
          vim.cmd("redrawtabline")
        end)
      end
    end,
  })
end

return M
