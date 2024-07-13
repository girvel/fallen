local interactive = require("tech.interactive")


local module = {}

module.SLOTS = {"main_hand", "main_glove"}

module.drop = function(parent, slot)
  local item = parent.inventory[slot]
  parent.inventory[slot] = nil
  item.position = parent.position
  State:refresh(item)
  State.grids[item.layer][item.position] = item
end

module.mixin = function()
  return Tablex.extend(
    interactive(function(self, other)
      if other.inventory[self.slot] then
        module.drop(other, self.slot)
      end
      other.inventory[self.slot] = self

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
