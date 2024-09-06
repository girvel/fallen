local perk = require("mech.perk")


local feats, _, static = Module("mech.feats")

feats.great_weapon_master = static {
  codename = "great_weapon_master",
  attack_modifier = -5,
  damage_modifier = 10,
  _gwm_condition = function(self, entity)
    local weapon = entity.inventory.main_hand
    return entity.perk_params[feats.great_weapon_master].enabled
      and weapon
      and weapon.tags.heavy
  end,
  modify_attack_roll = function(self, entity, roll)
    if not self:_gwm_condition(entity) then return roll end
    return roll + self.attack_modifier
  end,
  modify_damage_roll = function(self, entity, roll, slot)
    if slot ~= "main_hand" or not self:_gwm_condition(entity) then return roll end
    return roll + self.damage_modifier
  end,
}

feats.savage_attacker = static {
  codename = "savage_attacker",
  modify_damage_roll = function(self, entity, roll)
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
