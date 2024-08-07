local to_expression = function(statement)
  return ("(function()\n%s\nend)()"):format(statement)
end

local handle_primitive
local stack, warnings
local allowed_big_upvalues = {}

local build_table = function(x, cache)
  local mt = getmetatable(x)
  if mt and mt.__serialize then
    local serialized = mt.__serialize(x)
    if type(serialized) == "function" then
      allowed_big_upvalues[serialized] = true
      return ("return %s()"):format(handle_primitive(serialized, cache, true))
    end
    return "return " .. serialized
  end

  cache.size = cache.size + 1
  cache[x] = cache.size

  local result = {}
  result[1] = "local _ = {}"
  result[2] = ("cache[%s] = _"):format(cache.size)

  local i = 3
  for k, v in pairs(x) do
    table.insert(stack, tostring(k))
    result[i] = ("_[%s] = %s"):format(
      handle_primitive(k, cache),
      handle_primitive(v, cache)
    )
    i = i + 1
    table.remove(stack)
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
    local upvalue = handle_primitive(v, cache)
    if not allowed_big_upvalues[x] and #upvalue > 1024 then
      table.insert(warnings, ("Big upvalue %s in %s"):format(k, table.concat(stack, ".")))
    end
    result[i + 2] = ("debug.setupvalue(_, %s, %s)"):format(i, upvalue)
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
  table = function(x, cache)
    return to_expression(build_table(x, cache))
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

return setmetatable({
  get_warnings = function() return {unpack(warnings)} end,
  ignore_upvalue_size = setmetatable({}, {__concat = function(self, other)
    allowed_big_upvalues[other] = true
    return other
  end}),
}, {
  __call = function(_, x)
    stack = {}
    warnings = {}
    local cache = {size = 0}
    local result
    if type(x) == "table" then
      result = build_table(x, cache)
    else
      result = "return " .. handle_primitive(x, cache)
    end

    return "local cache = {}\n" .. result
  end
})
