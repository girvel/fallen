local creature = require("core.creature")
local level = require("level")
local mech = require("core.mech")


local module = {}

module.move = function(direction_name)
  return function(entity, state)
    entity.direction = direction_name
    if (
      entity.turn_resources.movement > 0 and
      level.move(state.grids[entity.layer], entity, entity.position + Vector[direction_name])
    ) then
      entity.turn_resources.movement = entity.turn_resources.movement - 1

      if entity.animate then
        entity:animate("move")
      end
    end
  end
end

local get_melee_attack_roll = function(entity)
  Log.trace(entity.inventory.main_hand)
  local roll = D(20) + entity.proficiency_bonus

  local weapon = entity.inventory.main_hand
  if not weapon then
    return roll + creature.get_modifier(entity.abilities.strength)
  end

  roll = roll + weapon.bonus
  if weapon.is_finesse then
    roll = roll + creature.get_modifier(math.max(
      entity.abilities.strength,
      entity.abilities.dexterity
    ))
  else
    roll = roll + creature.get_modifier(entity.abilities.strength)
  end

  return roll
end

local get_melee_damage_roll = function(entity)
  if not entity.inventory.main_hand then
    return D.roll({}, creature.get_modifier(entity.abilities.strength) + 1)
  end

  if entity.inventory.main_hand.is_finesse then
    return entity.inventory.main_hand.damage_roll
      + creature.get_modifier(math.max(
        entity.abilities.strength,
        entity.abilities.dexterity
      ))
  end

  return entity.inventory.main_hand.damage_roll
    + creature.get_modifier(entity.abilities.strength)
end

module.hand_attack = function(entity, state, target)
  if entity.turn_resources.actions <= 0
    or not target
    or not target.hp
  then
    return false
  end

  entity.turn_resources.actions = entity.turn_resources.actions - 1

  entity:animate("attack")
  entity:when_animation_ends(function()
    mech.attack(
      entity, state, target,
      get_melee_attack_roll(entity),
      get_melee_damage_roll(entity)
    )
  end)
end

module.sneak_attack = function(entity, state, target)
  if entity.turn_resources.actions <= 0
    or not target
    or not target.hp
    or not entity.inventory.main_hand
    or not entity.inventory.main_hand.is_finesse
    or not entity.turn_resources.has_advantage
  then
    return false
  end

  entity.turn_resources.actions = entity.turn_resources.actions - 1

  entity:animate("attack")
  entity:when_animation_ends(function()
    mech.attack(
      entity, state, target,
      get_melee_attack_roll(entity),
      get_melee_damage_roll(entity)
        + D(6) * math.ceil(entity.level / 2)
    )
  end)
end

module.aim = function(entity)
  if entity.turn_resources.bonus_actions <= 0
    or entity.turn_resources.movement < 6 -- TODO magic constant
  then
    return false
  end

  entity.turn_resources.bonus_actions = entity.turn_resources.bonus_actions - 1
  entity.turn_resources.movement = entity.turn_resources.movement - 6

  entity.turn_resources.has_advantage = true
end

return module
