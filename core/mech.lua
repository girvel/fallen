local special = require("tech.special")
local item = require("tech.item")


local module = {}

--- Attacks with given attack/damage rolls
module.attack = function(entity, target, attack_roll, damage_roll)
  local attack = attack_roll:with_advantage(entity.turn_resources.has_advantage):roll()
  local is_nat = attack == attack_roll:max()

  Log.info(
    Common.get_name(entity) .. " attacks " .. Common.get_name(target) .. "; attack roll: " ..
    attack .. ", armor: " .. target:get_armor()
  )

  if attack < target:get_armor() and not is_nat then
    State:add(special.floating_damage("-", target.position))
    return false
  end

  local is_critical = is_nat and attack >= target:get_armor()
  if is_critical then
    damage_roll = damage_roll + D.roll(damage_roll.dice, 0)
  end

  module.damage(target, damage_roll:roll(), is_critical)

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
  if target.hp <= 0 and not target.immortal then
    item.drop(target)
    State:remove(target)
    Log.info(Common.get_name(target) .. " is killed")
  end
end

return module
