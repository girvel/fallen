local rogue, module_mt, static = Module("mech.classes.rogue")

rogue.sneak_attack = function(entity, target)
  if entity.resources.actions <= 0
    or not target
    or not target.hp
    or not entity.inventory.main_hand
    or not entity.inventory.main_hand.is_finesse
    or not entity.resources.has_advantage
  then
    return false
  end

  entity.resources.actions = entity.resources.actions - 1

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

rogue.aim = function(entity)
  if entity.resources.bonus_actions <= 0
    or entity.resources.movement < constants.DEFAULT_MOVEMENT_SPEED
  then
    return
  end

  entity.resources.bonus_actions = entity.resources.bonus_actions - 1
  entity.resources.movement = entity.resources.movement - constants.DEFAULT_MOVEMENT_SPEED

  entity.resources.has_advantage = true
end

return rogue
