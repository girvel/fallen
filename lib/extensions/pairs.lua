return function(t)
  if OrderedMap.is(t) then return OrderedMap.pairs(t) end
  return pairs(t)
end
