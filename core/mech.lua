local special = require("tech.special")
local item = require("tech.item")


local module = {}

--- Attacks with given attack/damage rolls
module.attack = function(entity, target, attack_roll, damage_roll)
  local attack = attack_roll:with_advantage(entity.turn_resources.has_advantage):roll()
  local is_nat = attack == attack_roll:max()
  local ac = (-Query(target):get_armor() or 0)

  Log.info(
    Common.get_name(entity) .. " attacks " .. Common.get_name(target) .. "; attack roll: " ..
    attack .. ", armor: " .. ac
  )

  if attack < ac and not is_nat then
    State:add(special.floating_damage("-", target.position))
    return false
  end

  local is_critical = is_nat and attack >= ac
  if is_critical then
    damage_roll = damage_roll + D.roll(damage_roll.dice, 0)
  end

  module.damage(target, damage_roll:roll(), is_critical)
  return true
end

module.attack_save = function(target, ability, save_dc, damage_roll)
  local save = -Query(target).saving_rolls[ability]:roll()
  if not save then return false end

  Log.info("%s rolls %s save %s against %s" % {
    Common.get_name(target), ability, save, save_dc
  })

  if save >= save_dc then
    State:add(special.floating_damage("-", target.position))
    return false
  end

  module.damage(target, damage_roll:roll())
  return true
end

--- Gives fixed damage, handles hp, death and SFX
module.damage = function(target, damage, is_critical)
  damage = math.max(0, damage)
  Log.info("damage: " .. damage)

  if is_critical then
    State:add(special.floating_damage(damage .. "!", target.position))
  else
    State:add(special.floating_damage(damage, target.position))
  end

  target.hp = target.hp - damage
  if target.hp <= 0 then
    Query(target):on_death()
    if not target.immortal then
      Fun.iter(-Query(target).inventory or {}):each(function(slot) item.drop(target, slot) end)
      State:remove(target)
      Log.info(Common.get_name(target) .. " is killed")
    end
  end
end

return module
