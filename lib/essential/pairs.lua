return function(t)
  local ordered_map = require("lib.types.ordered_map")
  if ordered_map.is(t) then return ordered_map.pairs(t) end
  return pairs(t)
end
