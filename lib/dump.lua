return function(x)
  local xtype = type(x)
  if xtype == "number" then
    return "return " .. x
  end
  if xtype == "string" then
    return "return " .. string.format("%q", x)
  end
  if xtype == "function" then
    return ([[return function(...) return load(%q)(...) end]]):format(string.dump(x))
  end
end
