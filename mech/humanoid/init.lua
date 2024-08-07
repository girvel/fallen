local creature = require("mech.creature")
local animated = require("tech.animated")


local base_pack = require("mech.humanoid.pack")
local pack_by_race = Memoize(function(race)
  return animated.colored_pack(base_pack, race.skin_color)
end)

return Module("mech.humanoid", function(base_object)
  assert(
    -Query(base_object).race.skin_color,
    "No color found for race " .. tostring(-Query(base_object).race.codename)
  )

  return Tablex.extend(
    {transparent_flag = true},
    creature(pack_by_race(base_object.race), base_object)
  )
end)
