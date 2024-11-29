local iteration = require "tech.iteration"
local module, _, static = Module("tech.item")

module.DROPPING_SLOTS = {"main_hand", "other_hand", "gloves", 1}

--- @alias has_inventory {inventory: table<string, table>, position: vector}

--- @param parent has_inventory
--- @param slot string | integer
--- @return boolean
module.drop = function(parent, slot)
  local drop_position = Fun.chain({Vector.zero}, Vector.directions)
    :map(function(d) return parent.position + d end)
    :filter(function(v)
      return (v == parent.position or not State.grids.solids[v])
        and not State.grids.items[v]
    end)
    :nth(1)
  if not drop_position then return false end

  local item = parent.inventory[slot]
  if not item then return true end
  parent.inventory[slot] = nil
  item.position = drop_position
  State:refresh(item)
  State.grids[item.layer][item.position] = item
  return true
end

--- Put item in the entity's inventory. 
--- Drops the item if entity can't take the item; contains logic for taking weapons.
--- @param entity has_inventory entity to receive the item
--- @param this_item table item to give
--- @return boolean success did item make it to the entity's inventory
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

  if not is_free then return false end

  entity.inventory[slot] = this_item

  this_item.direction = entity.direction
  this_item:animate()
  this_item:animation_set_paused(-Query(entity.animation).paused)

  return true
end

module.mixin = function()
  local interactive = require("tech.interactive")

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
    end, {highlight = true}),
    {
      layer = "items",
      view = "scene",
      direction = "right",

      to_display = function(self)
        local postfix = ""
        if self.damage_roll then
          local damage_roll = self.tags.versatile
            and D(self.damage_roll.dice[1].sides_n + 2)
            or self.damage_roll

          postfix = postfix .. " (%s%s)" % {
            damage_roll,
            (self.bonus or 0) ~= 0 and "%+i" % self.bonus or ""
          }
        end
        return Entity.name(self) .. postfix
      end,
    }
  )
end

return module
