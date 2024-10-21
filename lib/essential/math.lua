local module = {}

--- Returns 1 if x is positive, -1 if negative, 0 if 0
--- @param x number
--- @return number
module.sign = function(x)
  if x == 0 then return 0 end
  return x / math.abs(x)
end

-- TODO unify median & average

--- @param ... number
--- @return number
module.median = function(...)
  local t = {...}
  table.sort(t)
  return t[math.ceil(#t / 2)]
end

--- @param t number[]
--- @return number
module.average = function(t)
  return Fun.iter(t):sum() / #t
end

--- Loops a in [1; b] the same way a % b loops a in [0; b - 1] in 0-based indexing
--- @param a number
--- @param b number
--- @return number
module.loopmod = function(a, b)
  return (a - 1) % b + 1
end

return module
