local module_mt = {}
local static = setmetatable({}, module_mt)

static._module = nil

local walk_table, process_table
static.module = function(path, t)
  assert(type(path) == "string", "Expected module name to be a string")
  static._module = path
  local result
  if type(t) == "function" then
    result = static(setmetatable({}, {__call = function(_, ...) return t(...) end}))
  else
    result = static(t or {})
  end
  local mt = getmetatable(result)
  mt.__newindex = function(self, k, v)
    if type(v) == "table" then
      process_table(v, {k}, path)
    end
    rawset(self, k, v)
  end
  return result, getmetatable(result)
end

process_table = function(v, path, module)
  local mt = getmetatable(v)
  if mt and mt.__module == module then
    static(path, v)
  end
end

walk_table = function(t, path, module)
  for k, v in pairs(t) do
    if type(v) == "table" then
      local new_path = Tablex.concat({}, path, {k})
      process_table(v, new_path, module)
      walk_table(v, new_path, module)
    end
  end
end

module_mt.__call = function(_, a, b)
  local path, value
  if b then
    path = type(a) == "string" and a / "." or a
    value = b
  else
    path = {}
    value = a
  end

  assert(type(value) == "table", "Only table values are supported")

  local mt = getmetatable(value)
  if not mt then
    mt = {}
    setmetatable(value, mt)
  end

  mt.__module = static._module
  local module = static._module
  mt.__serialize = function()
    return function() return Common.get_by_path(require(module), path) end
  end

  walk_table(value, path, static._module)

  return value
end

return static
