-- Custom tabline configuration
local M = {}

-- Custom tabline function to show buffers as tabs
function _G.custom_tabline()
  local tabline = ''
  local current_buf = vim.api.nvim_get_current_buf()
  local buf_list = vim.api.nvim_list_bufs()
  local count_by_filename = {}
  local bufs = {}

  -- Collect buffer information
  for _, buf in ipairs(buf_list) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_option(buf, 'buflisted') then
      local bufname = vim.api.nvim_buf_get_name(buf)
      local buftype = vim.api.nvim_buf_get_option(buf, 'buftype')
      local filename = vim.fn.fnamemodify(bufname, ':t')

      -- Skip special buffers
      if buftype == ''
        and bufname ~= ''
        and not bufname:match('NvimTree')
        and filename ~= ''
        and filename ~= '[No Name]'
      then
        count_by_filename[filename] = count_by_filename[filename] or 0
        count_by_filename[filename] = count_by_filename[filename] + 1
        table.insert(bufs, {
          buf = buf,
          bufname = bufname,
          buftype = buftype,
          filename = filename,
          rel_bufname = vim.fn.fnamemodify(bufname, ':.')
        })
      end
    end
  end

  -- Build tabline
  for _, buf_data in ipairs(bufs) do
    local modified = vim.api.nvim_buf_get_option(buf_data.buf, 'modified') and '*' or ''

    -- Highlight if is the current buf
    if buf_data.buf == current_buf then
      tabline = tabline .. '%#TabLineSel#'
    else
      tabline = tabline .. '%#TabLine#'
    end

    -- Add the buffer number
    tabline = tabline .. ' ' .. buf_data.buf .. ':'

    -- Use relative buffer name if more than one buffers with the same name
    if count_by_filename[buf_data.filename] > 1 then
      tabline = tabline .. buf_data.rel_bufname
    else
      tabline = tabline .. buf_data.filename
    end

    -- End buffer tab
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
      -- Skip nvim-tree and other special buffers
      local buftype = vim.api.nvim_buf_get_option(event.buf, 'buftype')
      local bufname = vim.api.nvim_buf_get_name(event.buf)
      
      if buftype == '' and not bufname:match('NvimTree') then
        vim.schedule(function()
          vim.cmd("redrawtabline")
        end)
      end
    end,
  })
end

return M
