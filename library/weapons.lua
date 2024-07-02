local interactive = require("tech.interactive")
local animated = require("tech.animated")


local module = {}

local weapon_mixin = function()
  return Tablex.extend(
    interactive(function(self, other)
      local dropped_weapon = other.inventory.main_hand
      other.inventory.main_hand = State:remove(self)
      if dropped_weapon then
        dropped_weapon.position = self.position
        State:add(dropped_weapon)
      end
    end),
    {layer = "items"}
  )
end

local rapier_pack = animated.load_pack("assets/sprites/rapier")
module.rapier = function()
  return Tablex.extend(
    weapon_mixin(),
    animated(rapier_pack),
    {
      direction = "right",
      name = "рапира",
      damage_roll = D(8),
      bonus = 0,
      tags = {
        finesse = true,
      },
      anchor = Vector({5, 11}),
    }
  )
end

-- module.shortsword = function()
--   return Tablex.extend(
--     weapon_mixin(),
--     static_sprite("assets/sprites/shortsword.png"),
--     {
--       name = "короткий меч",
--       damage_roll = D(6),
--       bonus = 0,
--       tags = {
--         finesse = true,
--         light = true,
--       },
--       anchor = Vector({4, 14}),
--     }
--   )
-- end

return module
