local M = {}

---Return `path` relative to `base`. Falls back to absolute if not inside `base`.
---@param path string absolute file path
---@param base string absolute directory path (reference)
---@return string
function M.relative(path, base)
  path = path or ""
  base = base or ""

  base = base:gsub('[\\/]+$', '')

  local norm = function(p) return p:gsub('[\\/]+', '/') end

  path = norm(path)
  base = norm(base)

  if path:sub(1, #base + 1) == base .. '/' then
    return path:sub(#base + 2)
  end

  return path
end

return M

