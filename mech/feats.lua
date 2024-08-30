local perk = require("mech.perk")


local feats, _, static = Module("mech.feats")

feats._gwm_condition = static .. function(entity)
  local weapon = entity.inventory.main_hand
  return entity.perk_params[feats.great_weapon_master].enabled
    and weapon
    and (weapon.tags.two_handed or weapon.tags.versatile and not entity.inventory.other_hand)
end

feats.great_weapon_master = static {
  codename = "great_weapon_master",
  attack_modifier = -5,
  damage_modifier = 10,
  modify_attack_roll = function(entity, roll)
    if not feats._gwm_condition(entity) then return roll end
    return roll + self.attack_modifier
  end,
  modify_damage_roll = function(entity, roll, slot)
    if slot ~= "main_hand" or not feats._gwm_condition(entity) then return roll end
    return roll + self.damage_modifier
  end,
}

feats.savage_attacker = static {
  codename = "savage_attacker",
  modify_damage_roll = function(entity, roll)
    local weapon = entity.inventory.main_hand
    if not weapon then return roll end
    return roll:extended({advantage = true})
  end,
}

feats.perk = static(perk.choice({
  feats.great_weapon_master,
  feats.savage_attacker,
}))

return feats
