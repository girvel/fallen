local abilities = require("mech.abilities")
local gui = require("tech.gui")
local item = require("tech.item")


local attacking, _, static = Module("mech.attacking")

--- Attacks with given attack/damage rolls
attacking.attack = function(entity, target, attack_roll, damage_roll)
  local attack = attack_roll:roll()
  local is_nat = attack == attack_roll:max()
  local is_nat_miss = attack == attack_roll:min()
  local ac = (-Query(target):get_armor() or 0)

  Log.info(
    Common.get_name(entity) .. " attacks " .. Common.get_name(target) .. "; attack roll: " ..
    attack .. ", armor: " .. ac
  )

  if is_nat_miss then
    State:add(gui.floating_damage("!", target.position))
    return false
  end

  if attack < ac and not is_nat then
    State:add(gui.floating_damage("-", target.position))
    return false
  end

  local is_critical = is_nat and attack >= ac
  if is_critical then
    damage_roll = damage_roll + D.roll(damage_roll.dice, 0)
  end

  attacking.damage(target, damage_roll:roll(), is_critical)
  return true
end

attacking.attack_save = function(target, ability, save_dc, damage_roll)
  if not -Query(target).saving_throws[ability] then return false end
  local success = abilities.saving_throw(target, ability, save_dc)

  if success then
    State:add(gui.floating_damage("-", target.position))
    return false
  end

  attacking.damage(target, damage_roll:roll())
  return true
end

--- Gives fixed damage, handles hp, death and SFX
attacking.damage = function(target, damage, is_critical)
  damage = math.max(0, damage)
  Log.info("damage: " .. damage)

  if is_critical then
    State:add(gui.floating_damage(damage .. "!", target.position))
  else
    State:add(gui.floating_damage(damage, target.position))
  end

  target.hp = target.hp - damage
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
    Log.info(Common.get_name(target) .. " is killed")
  end
end

return attacking
