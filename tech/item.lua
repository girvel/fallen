local interactive = require("tech.interactive")


local module, _, static = Module("tech.item")

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
  if not item then return true end
  parent.inventory[slot] = nil
  item.position = drop_position
  State:refresh(item)
  State.grids[item.layer][item.position] = item
  return true
end

module.give = function(entity, this_item)
  local slot
  local is_free
  if this_item.slot == "hands" then
    if this_item.tags.two_handed or not this_item.tags.light then
      is_free = (
        (not entity.inventory.main_hand or module.drop(entity, "main_hand"))
        and (not entity.inventory.other_hand or module.drop(entity, "other_hand"))
      )
      slot = "main_hand"
    else
      if not entity.inventory.main_hand
        or (not entity.inventory.main_hand.tags.light and module.drop(entity, "main_hand"))
      then
        slot = "main_hand"
        is_free = true
      elseif entity.inventory.main_hand.tags.light and not entity.inventory.other_hand then
        slot = "other_hand"
        is_free = true
      elseif entity.inventory.main_hand.tags.light and module.drop(entity, "other_hand") then
        entity.inventory.other_hand = entity.inventory.main_hand
        entity.inventory.main_hand = nil
        slot = "main_hand"
        is_free = true
      else
        is_free = false
      end
    end
  else
    is_free = not entity.inventory[this_item.slot] or module.drop(entity, this_item.slot)
    slot = this_item.slot
  end

  if is_free then
    entity.inventory[slot] = this_item

    this_item.direction = entity.direction
    this_item:animate()
  end

  return is_free
end

module.mixin = function()
  return Table.extend(
    interactive(function(self, other)
      local old_position = self.position
      State.grids[self.layer][self.position] = nil
      self.position = nil
      State:refresh(self)

      if not module.give(other, self) then
        self.position = old_position
        State.grids[self.layer][self.position] = self
        State:refresh(self)
        return
      end
    end),
    {
      layer = "items",
      view = "scene",
      direction = "right",
    }
  )
end

return module
