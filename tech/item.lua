local interactive = require("tech.interactive")


local module = {}

module.drop = function(parent)
  local weapon = -Query(parent).inventory.main_hand
  if not weapon then return end

  parent.inventory.main_hand = nil
  weapon.position = parent.position
  State:refresh(weapon)
  State.grids[weapon.layer][weapon.position] = weapon
end

module.weapon_mixin = function()
  return Tablex.extend(
    interactive(function(self, other)
      module.drop(other)
      other.inventory.main_hand = self

      State.grids[self.layer][self.position] = nil
      self.position = nil
      State:refresh(self)

      self.direction = other.direction
      self:animate()
    end),
    {layer = "items", view = "scene"}
  )
end

return module
