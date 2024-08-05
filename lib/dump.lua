local primitives

local build_table = function(x)
  local result = {}
  result[1] = "local _ = {}"

  local i = 2
  for k, v in pairs(x) do
    result[i] = ("_[%s] = %s"):format(
      primitives[type(k)](k), primitives[type(v)](v)
    )
    i = i + 1
  end

  result[i] = "return _"

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
    return ([[load(%q)]]):format(string.dump(x))
  end,
  table = function(x)
    return ("(function()\n%s\nend)()"):format(build_table(x))
  end,
  ["nil"] = function(x)
    return "nil"
  end,
  boolean = function(x)
    return tostring(x)
  end,
}

return function(x)
  local xtype = type(x)
  if xtype == "table" then
    return build_table(x)
  end

  return "return " .. primitives[xtype](x)
end
