local ordered_map = require("lib.types.ordered_map")

return function(t)
  if ordered_map.is(t) then return ordered_map.pairs(t) end
  return pairs(t)
end
