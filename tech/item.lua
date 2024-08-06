local interactive = require("tech.interactive")


local module = Static.module("tech.item")

module.DROPPING_SLOTS = {"main_hand", "other_hand", "gloves"}

module.drop = function(parent, slot)
  local drop_position = Fun.chain({Vector.zero}, Vector.directions)
    :map(function(d) return parent.position + d end)
    :filter(function(v)
      return (v == parent.position or not State.grids.solids[v])
        and not State.grids.items[v]
    end)
    :nth(1)
  if not drop_position then return end

  local item = parent.inventory[slot]
  parent.inventory[slot] = nil
  item.position = drop_position
  State:refresh(item)
  State.grids[item.layer][item.position] = item
  return true
end

module.mixin = function()
  return Tablex.extend(
    interactive(function(self, other)
      local old_position = self.position
      State.grids[self.layer][self.position] = nil
      self.position = nil
      State:refresh(self)

      local slot
      local is_free
      if self.slot == "hands" then
        if self.tags.two_handed or not self.tags.light then
          is_free = (
            (not other.inventory.main_hand or module.drop(other, "main_hand"))
            and (not other.inventory.other_hand or module.drop(other, "other_hand"))
          )
          slot = "main_hand"
        else
          if not other.inventory.main_hand
            or (not other.inventory.main_hand.tags.light and module.drop(other, "main_hand"))
          then
            slot = "main_hand"
            is_free = true
          elseif other.inventory.main_hand.tags.light and not other.inventory.other_hand then
            slot = "other_hand"
            is_free = true
          elseif other.inventory.main_hand.tags.light and module.drop(other, "other_hand") then
            other.inventory.other_hand = other.inventory.main_hand
            other.inventory.main_hand = nil
            slot = "main_hand"
            is_free = true
          else
            is_free = false
          end
        end
      else
        is_free = not other.inventory[self.slot] or module.drop(other, self.slot)
        slot = self.slot
      end

      if not is_free then
        self.position = old_position
        State.grids[self.layer][self.position] = self
        State:refresh(self)
        return
      end

      other.inventory[slot] = self

      self.direction = other.direction
      self:animate()
    end),
    {
      layer = "items",
      view = "scene",
      direction = "right",
    }
  )
end

return module
