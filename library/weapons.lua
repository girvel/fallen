local interactive = require("tech.interactive")
local animated = require("tech.animated")
local animation_packs = require("library.animation_packs")


local module = {}

local weapon_mixin = function()
  return Tablex.extend(
    interactive(function(self, other)
      local dropped_weapon = other.inventory.main_hand
      other.inventory.main_hand = State:remove(self)
      self.direction = other.direction
      self:animate()
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
    animated(animation_packs.rapier),
    {
      direction = "right",
      name = "рапира",
      damage_roll = D(8),
      bonus = 0,
      tags = {
        finesse = true,
      },
    }
  )
end

module.greatsword = function()
  return Tablex.extend(
    weapon_mixin(),
    animated(animation_packs.greatsword),
    {
      direction = "right",
      name = "двуручный меч",
      damage_roll = D(6) * 2,
      bonus = 0,
      tags = {
        two_handed = true,
        heavy = true,
      },
    }
  )
end

return module
