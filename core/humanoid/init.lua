local creature = require("core.creature")
local animated = require("tech.animated")


local base_pack = require("core.humanoid.pack")
local pack_by_race = Memoize(function(race)
  return animated.colored_pack(base_pack, race.skin_color)
end)

return function(base_object)
  assert(
    -Query(base_object).race.skin_color,
    "No color found for race " .. tostring(-Query(base_object).race.codename)
  )

  return Tablex.extend(
    {},
    creature(pack_by_race(base_object.race), base_object)
  )
end
