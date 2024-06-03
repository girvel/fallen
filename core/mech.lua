local special = require("special")


local module = {}

--- Attacks with given attack/damage rolls
module.attack = function(state, target, attack_roll, damage_roll)
  local attack, is_nat = attack_roll:roll()

  Log.info(
    target.name .. " is attacked; attack roll: " ..
    attack .. ", armor: " .. target:get_armor()
  )

  if attack < target:get_armor() and not is_nat then
    state:add(special.floating_damage("-", target.position))
    return false
  end

  local is_critical = is_nat and attack >= target:get_armor()
  if is_critical then
    damage_roll = damage_roll + D.roll(damage_roll.dice, 0)
  end

  module.damage(target, state, damage_roll:roll(), is_critical)

  return true
end

--- Gives fixed damage, handles hp, death and SFX
module.damage = function(target, state, damage, is_critical)
  damage = math.max(0, damage)
  Log.info("damage: " .. damage)

  if is_critical then
    state:add(special.floating_damage(damage .. "!", target.position))
  else
    state:add(special.floating_damage(damage, target.position))
  end

  target.hp = target.hp - damage
  if target.hp <= 0 then
    state:remove(target)
    Log.info(target.name .. " is killed")
  end
end

return module
