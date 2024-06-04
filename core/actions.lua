local creature = require("core.creature")
local level = require("level")
local random = require("utils.random")
local special = require("special")
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

module.hand_attack = function(entity, state, target)
  if entity.turn_resources.actions <= 0
    or not target
    or not target.hp
  then
    return false
  end

  entity.turn_resources.actions = entity.turn_resources.actions - 1

  entity:animate("attack")
  entity:when_ends(function()
    local damage_roll
    if entity.inventory.main_hand then
      damage_roll = entity.inventory.main_hand.damage_roll
        + creature.get_modifier(entity.abilities.strength)
    else
      damage_roll = D.roll({}, creature.get_modifier(entity.abilities.strength) + 1)
    end

    mech.attack(
      entity, state, target,
      D(20)
        + creature.get_modifier(entity.abilities.strength)
        + entity.proficiency_bonus,
      damage_roll
    )
  end)
end

module.sneak_attack = function(entity, state, target)
  if entity.turn_resources.actions <= 0
    or not target
    or not target.hp
    or not entity.inventory.main_hand
    or not entity.turn_resources.has_advantage
  then
    return false
  end

  entity.turn_resources.actions = entity.turn_resources.actions - 1

  return mech.attack(
    entity, state, target,
    D(20) + creature.get_modifier(entity.abilities.strength) + entity.proficiency_bonus,
    entity.inventory.main_hand.damage_roll
      + D(6) * math.ceil(entity.level / 2)
      + creature.get_modifier(entity.abilities.strength)
  )
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
