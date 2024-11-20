local abilities = require("mech.abilities")
local gui = require("tech.gui")
local health = require("mech.health")


local attacking, _, static = Module("mech.attacking")

--- Attacks with given attack/damage rolls
--- @param entity table entity doing the attacking
--- @param target {hp: number, position: table, invincible: boolean?} attacked entity
--- @param attack_roll table
attacking.attack = function(entity, target, attack_roll, damage_roll)
  -- TODO entity is here for logging purposes only; advantage_flag should probably be used in an action. entity argument should probably be removed.
  if entity.advantage_flag then  -- TODO RM with conditions
    attack_roll = attack_roll:extended {advantage = true}
  end
  local attack = attack_roll:roll()
  local is_nat = attack == attack_roll:max()
  local is_nat_miss = attack == attack_roll:min()
  local ac = (-Query(target):get_armor() or 0)

  Log.info("%s attacks %s; attack roll: %s, armor: %s" % {
    Entity.name(entity), Entity.name(target), attack, ac
  })

  if is_nat_miss then
    State:add(gui.floating_damage("!", target.position))
    return false
  end

  if target.invincible or attack < ac and not is_nat then
    State:add(gui.floating_damage("-", target.position))
    return false
  end

  local is_critical = is_nat and attack >= ac
  if is_critical then
    damage_roll = damage_roll + D.roll(damage_roll.dice, 0)
  end

  health.damage(target, damage_roll:roll(), is_critical)
  return true
end

attacking.attack_save = function(target, ability, save_dc, damage_roll)
  local success = abilities.saving_throw(target, ability, save_dc)

  if success then
    State:add(gui.floating_damage("-", target.position))
    return false
  end

  health.damage(target, damage_roll:roll())
  return true
end

return attacking
