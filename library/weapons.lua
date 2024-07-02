local static_sprite = require("tech.static_sprite")
local interactive = require("tech.interactive")


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

module.rapier = function()
  return Tablex.extend(
    weapon_mixin(),
    static_sprite("assets/sprites/rapier.png"),
    {
      name = "рапира",
      damage_roll = D(8),
      bonus = 0,
      tags = {
        finesse = true,
      },
    }
  )
end

module.shortsword = function()
  return Tablex.extend(
    weapon_mixin(),
    static_sprite("assets/sprites/shortsword.png"),
    {
      name = "короткий меч",
      damage_roll = D(6),
      bonus = 0,
      tags = {
        finesse = true,
        light = true,
      },
    }
  )
end

return module
