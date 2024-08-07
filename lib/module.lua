local _process_table, _walk_table, _make_table_static

_process_table = function(t, module_path, key_path)
  local mt = getmetatable(t)
  if mt and mt.__module == module_path then
    _make_table_static(t, module_path, key_path)
  end
end

_walk_table = function(t, module_path, key_path)
  for k, v in pairs(t) do
    if type(v) == "table" then
      local new_key_path = Tablex.concat({}, key_path, {k})
      _process_table(v, module_path, new_key_path)
      _walk_table(v, module_path, new_key_path)
    end
  end
end

_make_table_static = function(t, module_path, key_path)
  local mt = getmetatable(t)
  if not mt then
    mt = {}
    setmetatable(t, mt)
  end

  mt.__module = module_path
  mt.__serialize = function(_)
    return function() return Common.get_by_path(require(module_path), key_path) end
  end
end

local get_static_keyword = function(module_path)
  return function(t)
    local ttype = type(t)
    assert(ttype == "table" or ttype == "function", "Only tables or functions can be static")

    if ttype == "function" then
      t = setmetatable({}, {__call = function(_, ...) return t(...) end})
    end

    _make_table_static(t, module_path, {})
    _walk_table(t, module_path, {})
    return t
  end
end

return function(module_path, module_value)
  module_value = module_value or {}
  assert(type(module_path) == "string", "Path to the module should be a string")
  local value_type = type(module_value)
  assert(
    value_type == "table" or value_type == "function",
    ("Module should be either table or function, got %s instead"):format(value_type)
  )

  local static = get_static_keyword(module_path)
  local mt = getmetatable(static(module_value))
  mt.__newindex = function(self, k, v)
    if type(v) == "table" then
      _process_table(v, module_path, {k})
    end
    rawset(self, k, v)
  end
  return module_value, mt, static
end
