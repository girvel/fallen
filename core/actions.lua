local creature = require("core.creature")
local level = require("tech.level")
local mech = require("core.mech")
local constants = require("core.constants")


local module = {}

-- Post-Plot MVP refactor plans:
-- Action: {cost, _isAvailable(), execute()}
-- Level-dependency is stored in class
-- Hotkey is stored in player AI
-- Picture, description etc. is stored in GUI

local get_melee_attack_roll = function(entity)
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
      + entity.inventory.main_hand.bonus
  end

  return entity.inventory.main_hand.damage_roll
    + creature.get_modifier(entity.abilities.strength)
end

module.move = Fun.iter(Vector.direction_names):map(function(direction_name)
  return direction_name, function(entity, state)
    entity.direction = direction_name
    local old_position = entity.position
    if (
      entity.turn_resources.movement > 0 and
      level.move(state.grids[entity.layer], entity, entity.position + Vector[direction_name])
    ) then
      entity.turn_resources.movement = entity.turn_resources.movement - 1

      Fun.iter(Vector.directions)
        :map(function(d) return state.grids.solids:safe_get(old_position + d) end)
        :filter(function(e)
          return e
            and e ~= entity
            and e.abilities
            and creature.are_hostile(entity, e)
            and e.turn_resources
            and e.turn_resources.reactions > 0
          end)
        :each(function(e)
          e.turn_resources.reactions = e.turn_resources.reactions - 1
          e.direction = Vector.name_from_direction(old_position - e.position)
          e:animate("attack")
          e:when_animation_ends(function()
            mech.attack(
              e, state, entity,
              get_melee_attack_roll(e),
              get_melee_damage_roll(e)
            )
          end)
        end)

      if entity.animate then
        entity:animate("move")
      end
    end
  end
end):tomap()

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
    or entity.turn_resources.movement < constants.DEFAULT_MOVEMENT_SPEED
  then
    return
  end

  entity.turn_resources.bonus_actions = entity.turn_resources.bonus_actions - 1
  entity.turn_resources.movement = entity.turn_resources.movement - constants.DEFAULT_MOVEMENT_SPEED

  entity.turn_resources.has_advantage = true
end

module.dash = function(entity)
  if entity.turn_resources.actions <= 0 then
    return
  end

  entity.turn_resources.actions = entity.turn_resources.actions - 1
  entity.turn_resources.movement = entity.turn_resources.movement + entity:get_turn_resources().movement
end

return module
