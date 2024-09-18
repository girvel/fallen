local module = {}

module.sign = function(x)
  return x / math.abs(x)
end

module.median = function(...)
  local t = {...}
  table.sort(t)
  return t[math.ceil(#t / 2)]
end

module.average = function(t)
  return Fun.iter(t):sum() / #t
end

return module
