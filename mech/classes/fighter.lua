local sound = require("tech.sound")
local action = require("tech.action")
local class = require("mech.class")
local abilities = require("mech.abilities")
local fx = require("tech.fx")
local healing = require("mech.healing")


local fighter, module_mt, static = Module("mech.classes.fighter")

fighter.second_wind = static {
  name = "второе дыхание",
  codename = "second_wind",

  action = static .. action {
    name = "второе дыхание",

    _get_description = action.descriptions.healing,

    cost = {
      bonus_actions = 1,
      second_wind = 1,
    },

    get_healing_roll = function(self, entity)
      return D(10) + entity.level
    end,

    _get_availability = function(self, entity)
      return entity.hp < entity:get_max_hp()
    end,

    _run = function(self, entity)
      State:add(fx("assets/sprites/fx/second_wind", "fx_under", entity.position))
      sound.play("assets/sounds/second_wind.mp3", .3, entity.position, "small")
      healing.heal(entity, self:get_healing_roll(entity):roll())
    end,
  },

  modify_resources = function(self, entity, base, rest_type)
    if rest_type == "short" or rest_type == "long" then
      base.second_wind = 1
    end
    return base
  end,

  modify_actions = class.provide_action,
}

fighter.action_surge = static {
  name = "всплеск действий",
  codename = "action_surge",

  action = static .. action {
    cost = {
      action_surge = 1,
    },
    _get_description = function(self, entity)
      return Html.stats {
        "+1 действие на один ход",
      }
    end,
    _run = function(self, entity)
      State:add(fx("assets/sprites/fx/action_surge_proto", "fx_under", entity.position))
      sound.play("assets/sounds/action_surge.mp3", .3, entity.position, "small")
      entity.resources.actions = entity.resources.actions + 1
    end,
  },

  modify_resources = function(self, entity, base, rest_type)
    if rest_type == "short" or rest_type == "long" then
      base.action_surge = 1
    end
    return base
  end,

  modify_actions = class.provide_action,
}

fighter.styles = static {
  two_handed = static {
    name = "бой двуручным оружием",
    codename = "two_handed_style",

    _reroll = {1, 2},

    get_description = function(self)
      local start = table.concat(self._reroll, ", ", 1, #self._reroll - 1)
      local finish = Table.last(self._reroll)

      return Html.span {
        Html.p {Html.stats {
          "Перебросить %s или %s на кости урона оружия в двух руках." % {
            start, finish
          },
        }},
        "Повышает средний урон для двуручного оружия и полуторного, взятого в обе руки",
      }
    end,

    modify_damage_roll = function(self, entity, roll)
      local weapon = entity.inventory.main_hand
      if not (weapon and (weapon.tags.two_handed or weapon.tags.versatile)) then
        return roll
      end
      return roll:extended({reroll = self._reroll})
    end,
  },

  duelist = static {
    codename = "duelist",
    name = "дуэлянт",

    _bonus = 2,

    get_description = function(self)
      return Html.stats {
        "Бонус %+i к урону одноручным рукопашным оружием, если во второй руке нет оружия."
          % self._bonus
      }
    end,

    modify_damage_roll = function(self, entity, roll)
      local weapon = entity.inventory.main_hand
      if not weapon or weapon.tags.two_handed or entity.inventory.other_hand then
        return roll
      end
      return roll + self._bonus
    end,
  },

  two_weapon_fighting = static {
    codename = "two_weapon_fighting",
    name = "бой двумя оружиями",

    get_description = function(self, entity)
      return Html.stats {
        "Добавляет модификатор характеристики к урону от атаки второй рукой."
      }
    end,

    modify_damage_roll = function(self, entity, roll, slot)
      local weapon = entity.inventory.other_hand
      if not weapon or slot ~= "other_hand" then
        return roll
      end
      return roll + abilities.get_melee_modifier(entity, slot)
    end,
  },
}

fighter.fighting_style = static .. class.choice {
  name = "стиль боя",
  options = {
    fighter.styles.two_handed,
    fighter.styles.duelist,
    fighter.styles.two_weapon_fighting
  },
}

fighter.fighting_spirit = static {
  name = "боевой дух",
  codename = "fighting_spirit",
  action = static .. action {
    cost = {
      fighting_spirit = 1,
      bonus_actions = 1,
    },
    _get_description = function(self, entity)
      return Html.stats {
        "+5 здоровья и преимущество на атаки до конца хода.",
      }
    end,
    _run = function(self, entity)
      State:add(fx("assets/sprites/fx/fighting_spirit", "fx_under", entity.position))
      entity.advantage_flag = true
      entity.hp = math.min(entity:get_max_hp(), entity.hp) + 5  -- TODO temp hp
    end,
  },

  modify_resources = function(self, entity, base, rest_type)
    if rest_type == "long" then
      base.fighting_spirit = 3
    end
    return base
  end,

  modify_actions = class.provide_action,
}

fighter.class = static {
  name = "воин",
  codename = "fighter",
  hp_die = 10,

  progression_table = static {
    [1] = {
      class.hit_dice,
      class.save_proficiency("con", "str"),
      fighter.fighting_style,
      fighter.second_wind,
    },
    [2] = {
      fighter.action_surge,
    },
    [3] = {
      fighter.fighting_spirit,
    },
  },
}

return fighter
