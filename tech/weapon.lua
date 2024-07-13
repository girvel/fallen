local interactive = require("tech.interactive")


local module = {}

module.mixin = function()
  return Tablex.extend(
    interactive(function(self, other)
      local dropped_weapon = other.inventory.main_hand
      other.inventory.main_hand = self

      State.grids[self.layer][self.position] = nil
      self.position = nil
      State:refresh(self)

      self.direction = other.direction
      self:animate()

      if dropped_weapon then
        dropped_weapon.position = other.position
        State:refresh(dropped_weapon)
        State.grids[dropped_weapon.layer][dropped_weapon.position] = dropped_weapon
      end
    end),
    {layer = "items", view = "scene"}
  )
end

return module
