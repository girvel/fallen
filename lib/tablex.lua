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
    if math.type(k) == "integer" then
      base[length + k] = v
    else
      base[k] = v
    end
  end
  return tablex.join(base, ...)
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
  return fun.iter(pairs(t))
    :filter(function(k, v) return v ~= item end)
    :tomap()
end

tablex.remove_breaking_at = function(t, i)
  t[i] = t[#t]
  t[#t] = nil
end

return tablex
