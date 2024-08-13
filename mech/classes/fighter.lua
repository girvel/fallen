local class = require("mech.class")
local perk = require("mech.perk")
local abilities = require("mech.abilities")
local fx = require("tech.fx")
local healing = require("mech.healing")


local fighter, module_mt, static = Module("mech.classes.fighter")

fighter.second_wind = static {
  codename = "second_wind",
  get_availabilities = function(self, entity)
    return entity.hp < entity:get_max_hp()
      and entity.resources.bonus_actions > 0
      and entity.resources.second_wind > 0
  end,
  _run = function(self, entity)
    entity.resources.bonus_actions = entity.resources.bonus_actions - 1
    entity.resources.second_wind = entity.resources.second_wind - 1
    State:add(fx("assets/sprites/fx/second_wind", "fx_behind", entity.position))
    healing.heal(entity, (D(10) + entity.level):roll())
  end,
}

fighter.action_surge = static {
  codename = "action_surge",
  get_availabilities = function(self, entity)
    return entity.resources.action_surge > 0
  end,
  _run = function(self, entity)
    entity.resources.action_surge = entity.resources.action_surge - 1
    State:add(fx("assets/sprites/fx/action_surge_proto", "fx_behind", entity.position))
    entity.resources.actions = entity.resources.actions + 1
  end,
}

-- TODO perk.choice.option is of type list<modifier>
--   but should be of type list<list<perk>>
fighter.fighting_style = static(perk.choice({
  {
    codename = "two_handed_style",
    modify_damage_roll = function(entity, roll)
      if not -Query(entity.inventory).main_hand.tags.two_handed then
        return roll
      end
      return roll:extended({reroll = {1, 2}})
    end,
  },

  {
    codename = "duelist",
    modify_damage_roll = function(entity, roll)
      local weapon = entity.inventory.main_hand
      if not weapon or weapon.tags.two_handed then
        return roll
      end
      return roll + 2
    end,
  },

  {
    codename = "two_weapon_fighting",
    modify_damage_roll = function(entity, roll, slot)
      local weapon = entity.inventory.other_hand
      if not weapon or slot ~= "other_hand" then
        return roll
      end
      return roll + abilities.get_melee_modifier(entity, slot)
    end,
  },
}))

fighter.progression_table = static {
  [1] = {
    perk.action(fighter.second_wind),
    perk.resource("short", "second_wind", 1),
    fighter.fighting_style,
  },
  [2] = {
    perk.action(fighter.action_surge),
    perk.resource("short", "action_surge", 1),
  },
}

-- TODO maybe not a factory?
module_mt.__call = function(_)
  return Tablex.extend(class.mixin(), {
    codename = "fighter",
    hp_die = 10,
    save_proficiencies = Common.set({"str", "con"}),

    progression_table = fighter.progression_table,
  })
end

return fighter
