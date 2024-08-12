local perk = require("mech.perk")


local feats, _, static = Module("mech.feats")

feats.great_weapon_master = static {
  codename = "great_weapon_master",
  modify_attack_roll = function(entity, roll)
    local weapon = entity.inventory.main_hand
    if not weapon or not weapon.tags.two_handed then return roll end
    return roll - 5
  end,
  modify_damage_roll = function(entity, roll, slot)
    if slot ~= "main_hand" then return roll end
    local weapon = entity.inventory.main_hand
    if weapon and (weapon.tags.two_handed or weapon.tags.versatile and not entity.inventory.other_hand) then
      return roll + 10
    end
    return roll
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
