local animated = require("tech.animated")
local item = require("tech.item")


--- Setting/removing visual on-entity cues such as highlights or blood.
local cues, module_mt, static = Module("tech.cue")

local factories = {
  blood = function()
    return Table.extend(
      animated("assets/sprites/animations/blood", "atlas"),
      {
        direction = "right",
        name = "Кровь",
        codename = "blood",
        slot = "blood",
      }
    )
  end,
}

--- Sets whether given cue should be or not be displayed
--- @param entity has_inventory
--- @param slot string
--- @param value boolean?
--- @return nil
cues.set = function(entity, slot, value)
  if Common.bool(value) == Common.bool(entity.inventory[slot]) then return end
  if value then
    item.give(entity, State:add(factories[slot]()))
  else
    State:remove(entity.inventory[slot])
    entity.inventory[slot] = nil
  end
end

return cues
