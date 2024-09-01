local metatable = function(t)
  local mt = getmetatable(t)
  if mt then return mt end
  mt = {}
  setmetatable(t, mt)
  return mt
end

local _process_table, _walk_table, _make_table_static

_process_table = function(t, module_path, key_path)
  local mt = getmetatable(t)
  if mt and mt.__module == module_path then
    _make_table_static(t, module_path, key_path)
  end
end

_walk_table = function(t, module_path, key_path, depth)
  if depth > 10 then return end
  for k, v in pairs(t) do
    if type(v) == "table" then
      local new_key_path = Table.concat({}, key_path, {k})
      _process_table(v, module_path, new_key_path)
      _walk_table(v, module_path, new_key_path, depth + 1)
    end
  end
end

_make_table_static = function(t, module_path, key_path)
  local mt = metatable(t)

  local key_path_copy = {unpack(key_path)}
  mt.__serialize = function(_)
    return function() return Common.get_by_path(require(module_path), key_path_copy) end
  end
  mt.__newindex = function(self, k, v)
    if type(v) == "table" then
      _process_table(v, module_path, {k})
      _walk_table(v, module_path, {k}, 1)
    end
    rawset(self, k, v)
  end
end

local get_static_keyword = function(module_path)
  local f = function(_, t)
    local ttype = type(t)
    assert(ttype == "table" or ttype == "function", "Only tables or functions can be static")

    if ttype == "function" then
      local inner = t
      t = setmetatable({}, {__call = function(_, ...) return inner(...) end})
    end

    metatable(t).__module = module_path
    return t
  end
  return setmetatable({}, {__call = f, __concat = f})
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
  module_value = static(module_value)
  _make_table_static(module_value, module_path, {})
  _walk_table(module_value, module_path, {}, 0)
  return module_value, getmetatable(module_value), static
end
