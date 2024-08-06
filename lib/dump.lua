local to_expression = function(statement)
  return ("(function()\n%s\nend)()"):format(statement)
end

local primitives

local build_table = function(x, cache)
  local cache_i = cache[x]
  if cache_i then
    return ("return cache[%s]"):format(cache_i)
  end

  local mt = getmetatable(x)
  if mt and mt.__serialize then
    local serialized = mt.__serialize(x)
    if type(serialized) == "function" then
      return ("return %s()"):format(primitives["function"](serialized, cache))
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
    result[i] = ("_[%s] = %s"):format(
      primitives[type(k)](k, cache),
      primitives[type(v)](v, cache)
    )
    i = i + 1
  end

  if not mt then
    result[i] = "return _"
  else
    result[i] = ("return setmetatable(_, %s)"):format(primitives[type(mt)](mt, cache))
  end

  return table.concat(result, "\n")
end

primitives = {
  number = function(x)
    return tostring(x)
  end,
  string = function(x)
    return string.format("%q", x)
  end,
  ["function"] = function(x, cache)
    local expression = ([[load(%q)]]):format(string.dump(x))
    if not debug.getupvalue(x, 1) then
      return expression
    end

    local result = {"local _ = " .. expression}
    for i = 1, math.huge do
      local k, v = debug.getupvalue(x, i)
      if not k then break end
      result[i + 1] = ("debug.setupvalue(_, %s, %s)"):format(
        i, primitives[type(v)](v, cache)
      )
    end
    table.insert(result, "return _")
    return to_expression(table.concat(result, "\n"))
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

return function(x)
  local xtype = type(x)
  assert(primitives[xtype], ("dump does not support type %q"):format(xtype))

  local cache = {size = 0}
  local result
  if xtype == "table" then
    result = build_table(x, cache)
  else
    result = "return " .. primitives[xtype](x, cache)
  end

  return "local cache = {}\n" .. result
end
