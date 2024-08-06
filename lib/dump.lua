local to_expression = function(statement)
  return ("(function()\n%s\nend)()"):format(statement)
end

local primitives

local build_table = function(x)
  local mt = getmetatable(x)
  if mt and mt.__serialize then
    local serialized = mt.__serialize(x)
    if type(serialized) == "function" then
      return ("return %s()"):format(primitives["function"](serialized))
    end
    return "return " .. serialized
  end

  local result = {}
  result[1] = "local _ = {}"

  local i = 2
  for k, v in pairs(x) do
    result[i] = ("_[%s] = %s"):format(
      primitives[type(k)](k), primitives[type(v)](v)
    )
    i = i + 1
  end

  if not mt then
    result[i] = "return _"
  else
    result[i] = ("return setmetatable(_, %s)"):format(primitives[type(mt)](mt))
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
  ["function"] = function(x)
    local expression = ([[load(%q)]]):format(string.dump(x))
    if not debug.getupvalue(x, 1) then
      return expression
    end

    local result = {"local _ = " .. expression}
    for i = 1, math.huge do
      local k, v = debug.getupvalue(x, i)
      if not k then break end
      result[i + 1] = ("debug.setupvalue(_, %s, %s)"):format(
        i, primitives[type(v)](v)
      )
    end
    table.insert(result, "return _")
    return to_expression(table.concat(result, "\n"))
  end,
  table = function(x)
    return to_expression(build_table(x))
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
  if xtype == "table" then
    return build_table(x)
  end

  return "return " .. primitives[xtype](x)
end
