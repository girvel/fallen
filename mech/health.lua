local gui = require("tech.gui")
local item = require("tech.item")
local cue  = require("tech.cue")


local health, module_mt, static = Module("mech.health")

---- @alias healthy {hp: integer, get_max_hp: fun(self): integer, immortal: true?}
--- @alias healthy any

--- Restores `amount` of `target`'s health with FX
--- @param target healthy
--- @param amount integer
--- @return nil
health.heal = function(target, amount)
  local value = target.hp + amount
  if target.get_max_hp then
    value = math.min(target:get_max_hp(), value)
  end
  health.set_hp(target, value)
  if target.position then
    State:add(gui.floating_damage("+" .. amount, target.position, Colors.light_green))
  end
end

--- Inflict fixed damage; handles hp, death and FX
--- @param target healthy
--- @param amount number
--- @param is_critical boolean? whether to display damage as critical
--- @return nil
health.damage = function(target, amount, is_critical)
  amount = math.max(0, amount)
  Log.info("damage: " .. amount)

  if is_critical then
    State:add(gui.floating_damage(amount .. "!", target.position))
  else
    State:add(gui.floating_damage(amount, target.position))
  end

  health.set_hp(target, target.hp - amount)
  if target.hp <= 0 then
    Query(target):on_death()
    if target.immortal then return end

    if target.inventory then
      for _, slot in ipairs(item.DROPPING_SLOTS) do
        local this_item = target.inventory[slot]
        if this_item and not this_item.disable_drop_flag then
          item.drop(target, slot)
        end
      end
    end

    State:remove(target)
    Log.info(Entity.name(target) .. " is killed")
  end
end

--- Set HP, update blood cue
--- @param target healthy
--- @param value integer
--- @return nil
health.set_hp = function(target, value)
  value = math.max(0, value)

  target.hp = value
  if target.get_max_hp then
    cue.set(target, "blood", target.hp <= target:get_max_hp() / 2)
  end
end

return health
