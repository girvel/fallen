local fun = require("lib.fun")


local tablex = {}

--- Copies all fields into the base
-- Modifies first argument, copying all the fields via pairs of the following arguments in order
-- from left to right.
tablex.extend = function(base, extension, ...)
  if extension == nil then return base end
  for k, v in pairs(extension) do
    base[k] = v
  end
  return tablex.extend(base, ...)
end

--- Concatenates lists into the base
-- Modifies first argument, copying all the fields via ipairs of the following arguments in order
-- from left to right
tablex.concat = function(base, extension, ...)
  if extension == nil then return base end
  for _, v in ipairs(extension) do
    table.insert(base, v)
  end
  return tablex.concat(base, ...)
end

--- Concatenates and extends into the base
-- Modifies first argument, first concatenating everything via ipairs, then copying all the
-- key-value data, both in order from left to right
tablex.join = function(base, extension, ...)
  if extension == nil then return base end
  local length = #base
  for k, v in pairs(extension) do
    if type(k) == "number" and math.floor(k) == k then
      base[length + k] = v
    else
      base[k] = v
    end
  end
  return tablex.join(base, ...)
end

tablex.index_of = function(t, item)
  return Fun.iter(t)
    :enumerate()
    :filter(function(i, x) return x == item end)
    :map(function(i, x) return i end)
    :nth(1)
end

--- Checks if the two tables are isomorphic on the first level on recursion
tablex.shallow_same = function(t1, t2)
  for k, v in pairs(t1) do
    if v ~= t2[k] then return false end
  end
  for k, _ in pairs(t2) do
    if not t1[k] then return false end
  end
  return true
end

tablex.deep_copy = function(o, seen)
  seen = seen or {}
  if o == nil then return nil end
  if seen[o] then return seen[o] end

  local no
  if type(o) == 'table' then
    no = {}
    seen[o] = no

    for k, v in next, o, nil do
      no[tablex.deep_copy(k, seen)] = tablex.deep_copy(v, seen)
    end
    setmetatable(no, tablex.deep_copy(getmetatable(o), seen))
  else
    no = o
  end
  return no
end

tablex.remove = function(t, item)
  for k, v in pairs(t) do
    if v == item then
      if math.ceil(k) == k then
        table.remove(t, k)
      else
        t[k] = nil
      end
    end
  end
  return t
end

tablex.remove_breaking_at = function(t, i)
  t[i] = t[#t]
  t[#t] = nil
end

tablex.contains = function(t, item)
  return Fun.iter(t):any(function(x) return x == item end)
end

return tablex
