local sound = require("tech.sound")
local action = require("tech.action")
local class = require("mech.class")
local abilities = require("mech.abilities")
local fx = require("tech.fx")
local healing = require("mech.healing")


local fighter, module_mt, static = Module("mech.classes.fighter")

fighter.second_wind = static {
  codename = "second_wind",

  action = static .. action {
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
  codename = "action_surge",
  action = static .. action {
    cost = {
      action_surge = 1,
    },
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
    codename = "two_handed_style",
    modify_damage_roll = function(self, entity, roll)
      local weapon = entity.inventory.main_hand
      if not (weapon and (weapon.tags.two_handed or weapon.tags.versatile)) then
        return roll
      end
      return roll:extended({reroll = {1, 2}})
    end,
  },

  duelist = static {
    codename = "duelist",
    modify_damage_roll = function(self, entity, roll)
      local weapon = entity.inventory.main_hand
      if not weapon or weapon.tags.two_handed then
        return roll
      end
      return roll + 2
    end,
  },

  two_weapon_fighting = static {
    codename = "two_weapon_fighting",
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
  fighter.styles.two_handed,
  fighter.styles.duelist,
  fighter.styles.two_weapon_fighting
}

fighter.fighting_spirit = static {
  codename = "fighting_spirit",
  action = static .. action {
    cost = {
      fighting_spirit = 1,
      bonus_actions = 1,
    },
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

fighter.progression_table = static {
  [1] = {
    class.hit_dice,
    fighter.fighting_style,
    fighter.second_wind,
  },
  [2] = {
    fighter.action_surge,
  },
  [3] = {
    fighter.fighting_spirit,
  },
}

fighter.class = static {
  codename = "fighter",
  hp_die = 10,
  save_proficiencies = Common.set({"str", "con"}),

  progression_table = fighter.progression_table,
}

return fighter
