local metatable = function(t)
  local mt = getmetatable(t)
  if mt then
    assert(mt.__unique, "Module data marked as static should have a unique metatable")
    return mt
  end
  mt = {__unique = true}
  setmetatable(t, mt)
  return mt
end

local process_table, walk_table, make_table_static

process_table = function(t, module_path, key_path)
  local mt = getmetatable(t)
  if mt and mt.__module == module_path then
    make_table_static(t, module_path, key_path)
  end
end

walk_table = function(t, module_path, key_path, depth)
  if depth > 10 then return end
  for k, v in pairs(t) do
    if type(v) == "table" then
      local new_key_path = Table.concat({}, key_path, {k})
      process_table(v, module_path, new_key_path)
      walk_table(v, module_path, new_key_path, depth + 1)
    end
  end
end

make_table_static = function(t, module_path, key_path)
  local mt = metatable(t)

  local key_path_copy = {unpack(key_path)}
  mt.__serialize = function(_)
    return function() return Common.get_by_path(require(module_path), key_path_copy) end
  end
  mt.__newindex = function(self, k, v)
    if type(v) == "table" then
      process_table(v, module_path, Table.concat({}, key_path_copy, {k}))
      walk_table(v, module_path, Table.concat({}, key_path_copy, {k}), 1)
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
      t = setmetatable({}, {
        __call = function(_, ...) return inner(...) end,
        __unique = true,
      })
    end

    metatable(t).__module = module_path
    return t
  end
  return setmetatable({}, {__call = f, __concat = f})
end

--- @param module_path string
--- @param module_value table|function?
return function(module_path, module_value)
  module_value = module_value or {}
  assert(type(module_path) == "string", "Path to the module should be a string")
  local value_type = type(module_value)
  assert(
    value_type == "table" or value_type == "function",
    ("Module should be either table or function, got %s instead"):format(value_type)
  )

  --- @module 'tech.identity'
  local static = get_static_keyword(module_path) --[[@as function]]

  local module_result = static(module_value) --[[@as table]]
  make_table_static(module_result, module_path, {})
  walk_table(module_result, module_path, {}, 0)

  return module_result, getmetatable(module_result), static
end
