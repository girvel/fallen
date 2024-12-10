local action = require("tech.action")
local class = require("mech.class")


local feats, _, static = Module("mech.feats")

feats.great_weapon_master = static {
  name = "мастер двуручного оружия",
  codename = "great_weapon_master",

  attack_modifier = -5,
  damage_modifier = 10,

  action = static(action {
    name = "Переключить тяжёлые атаки",
    codename = "toggle_gwm",
    _get_description = function(self)
      return Html.stats {
        "%+i" % feats.great_weapon_master.attack_modifier, " к атаке", Html.br {},
        "%+i" % feats.great_weapon_master.damage_modifier, " к урону", Html.br {},
        "Тяжёлое оружие",
      }
    end,
    _run = function(self)
      local params = State.player.effect_params[feats.great_weapon_master]
      params.enabled = not params.enabled
    end,
  }),

  _gwm_condition = function(self, entity)
    local weapon = entity.inventory.main_hand
    return entity.effect_params[self].enabled
      and weapon
      and weapon.tags.heavy
  end,

  initialize_params = function(self)
    return {enabled = true}
  end,

  modify_attack_roll = function(self, entity, roll)
    if not self:_gwm_condition(entity) then return roll end
    return roll + self.attack_modifier
  end,

  modify_damage_roll = function(self, entity, roll, slot)
    if slot ~= "main_hand" or not self:_gwm_condition(entity) then return roll end
    return roll + self.damage_modifier
  end,

  modify_actions = class.provide_action,
}

feats.savage_attacker = static {
  name = "свирепый атакующий",
  codename = "savage_attacker",
  modify_damage_roll = function(self, entity, roll)
    local weapon = entity.inventory.main_hand
    if not weapon then return roll end
    return roll:extended({advantage = true})
  end,
  get_description = function()
    return Html.span {
      Html.p {Html.stats {"Бросать кости урона в рукопашном бою с преимуществом."}},
      Html.p {"Увеличивает средний урон в рукопашном бою."},
    }
  end
}

feats.perk = static .. class.choice {
  name = "Черта",
  options = {
    feats.savage_attacker,
    feats.great_weapon_master,  -- should not go first, too powerful
  },
}

return feats
