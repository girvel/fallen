local line_profiler = require("lib.line_profiler")
local animated = require("tech.animated")
local item = require("tech.item")


--- Setting/removing visual on-entity cues such as highlights or blood.
local cue, module_mt, static = Module("tech.cue")

--- @enum (key) cue_slot
cue.factories = {
  blood = function()
    return Table.extend(
      animated("assets/sprites/animations/blood", "atlas"),
      {
        name = "Кровь",
        codename = "blood",
        slot = "blood",
      }
    )
  end,

  highlight = function()
    return Table.extend(
      animated("assets/sprites/animations/highlight"),
      {
        name = "Хайлайт",
        codename = "highlight",
        slot = "highlight",
        animated_independently_flag = true,
        boring_flag = true,
      }
    )
  end,
}

--- Sets whether given cue should be or not be displayed
--- @param entity has_inventory
--- @param slot cue_slot
--- @param value boolean
--- @return nil
cue.set = function(entity, slot, value)
  local factory = assert(cue.factories[slot], "Slot %q is not supported" % {slot})

  if not entity.inventory then entity.inventory = {} end
  if Common.bool(value) == Common.bool(entity.inventory[slot]) then return end
  if value then
    item.give(entity, State:add(factory()))
  else
    State:remove(entity.inventory[slot])
    entity.inventory[slot] = nil
  end
end

return cue
