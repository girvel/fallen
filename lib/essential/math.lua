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

--- Loops a in [1; b] the same way a % b loops a in [0; b - 1] in 0-based indexing
module.loopmod = function(a, b)
  return (a - 1) % b + 1
end

return module
