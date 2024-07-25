local module_mt = {}
local rogue = setmetatable({}, module_mt)

module.sneak_attack = function(entity, target)
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
    attacking.attack(
      entity, target,
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

return rogue
