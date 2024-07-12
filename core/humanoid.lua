local creature = require("core.creature")
local animated = require("tech.animated")
local races = require("core.races")


local base_pack = animated.load_pack("assets/sprites/humanoid", {
  idle_right = {
    Vector({3, 12}),
  },
  idle_left = {
    Vector({11, 12}),
  },
  idle_down = {
    Vector({3, 12}),
  },
  idle_up = {
    Vector({11, 12}),
  },
  attack_right = {
    Vector({2, 12}),
    Vector({14, 11}),
  },
  attack_left = {
    Vector({12, 12}),
    Vector({0, 11}),
  },
  attack_down = {
    Vector({3, 11}),
    Vector({3, 15}),
  },
  attack_up = {
    Vector({11, 13}),
    Vector({11, 8}),
  },
  move_right = {
    Vector({3, 12}),
    Vector({3, 12}),
    Vector({3, 12}),
  },
  move_left = {
    Vector({11, 12}),
    Vector({11, 12}),
    Vector({11, 12}),
  },
  move_down = {
    Vector({3, 12}),
    Vector({3, 12}),
    Vector({3, 12}),
  },
  move_up = {
    Vector({11, 12}),
    Vector({11, 12}),
    Vector({11, 12}),
  },
})

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
