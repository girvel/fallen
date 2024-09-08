local creature = require("mech.creature")
local animated = require("tech.animated")


local humanoid, module_mt, static = Module("mech.humanoid")


humanoid._base_pack = static .. animated.load_atlas_pack("assets/sprites/animations/humanoid")
local pack_by_race = Memoize(function(race)
  return animated.colored_pack(humanoid._base_pack, race.skin_color)
end)

module_mt.__call = function(_, base_object)
  assert(
    -Query(base_object).race.skin_color,
    "No color found for race " .. tostring(-Query(base_object).race.codename)
  )

  return Table.extend(
    {transparent_flag = true, size = Vector.one},
    creature(pack_by_race(base_object.race), base_object)
  )
end

return humanoid
