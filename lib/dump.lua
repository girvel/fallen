local to_expression = function(statement)
  return ("(function()\n%s\nend)()"):format(statement)
end

local handle_primitive

local build_table = function(x, cache)
  local mt = getmetatable(x)
  if mt and mt.__serialize then
    local serialized = mt.__serialize(x)
    if type(serialized) == "function" then
      return ("return %s()"):format(handle_primitive(serialized, cache))
    end
    return "return " .. serialized
  end

  -- if x.name or x.codename then
  --   Log.trace("===", Common.get_name(x), "===")
  -- end

  cache.size = cache.size + 1
  cache[x] = cache.size

  local result = {}
  result[1] = "local _ = {}"
  result[2] = ("cache[%s] = _"):format(cache.size)

  local i = 3
  for k, v in pairs(x) do
    -- Log.trace(k, type(k))
    result[i] = ("_[%s] = %s"):format(
      handle_primitive(k, cache),
      handle_primitive(v, cache)
    )
    i = i + 1
  end

  if not mt then
    result[i] = "return _"
  else
    result[i] = ("return setmetatable(_, %s)"):format(handle_primitive(mt, cache))
  end

  return table.concat(result, "\n")
end

local build_function = function(x, cache)
  cache.size = cache.size + 1
  cache[x] = cache.size

  local result = {}
  result[1] = "local _ = " .. ([[load(%q)]]):format(string.dump(x))
  result[2] = ("cache[%s] = _"):format(cache.size)

  for i = 1, math.huge do
    local k, v = debug.getupvalue(x, i)
    if not k then break end
    result[i + 2] = ("debug.setupvalue(_, %s, %s)"):format(
      i, handle_primitive(v, cache)
    )
  end
  table.insert(result, "return _")
  return table.concat(result, "\n")
end

local primitives = {
  number = function(x)
    return tostring(x)
  end,
  string = function(x)
    return string.format("%q", x)
  end,
  ["function"] = function(x, cache)
    return to_expression(build_function(x, cache))
  end,
  table = function(...)
    return to_expression(build_table(...))
  end,
  ["nil"] = function()
    return "nil"
  end,
  boolean = function(x)
    return tostring(x)
  end,
}

handle_primitive = function(x, cache)
  local xtype = type(x)
  assert(primitives[xtype], ("dump does not support type %q"):format(xtype))

  if xtype == "table" or xtype == "function" then
    local cache_i = cache[x]
    if cache_i then
      return ("cache[%s]"):format(cache_i)
    end
  end

  return primitives[xtype](x, cache)
end

return function(x)
  local cache = {size = 0}
  local result
  if type(x) == "table" then
    result = build_table(x, cache)
  else
    result = "return " .. handle_primitive(x, cache)
  end

  return "local cache = {}\n" .. result
end
