local static_sprite = require("tech.static_sprite")
local class = require("mech.class")
local perk = require("mech.perk")


local module_mt = {}
local fighter = setmetatable({}, module_mt)

fighter.second_wind = Tablex.extend(
  static_sprite("assets/sprites/icons/second_wind.png"),
  {
    codename = "second_wind",
    size = Vector.one * 0.67,
    on_click = function(self, entity) return entity:act(self) end,
    get_availability = function(self, entity)
      return entity.resources.bonus_actions > 0
        and entity.resources.second_wind > 0
    end,
    _run = function(self, entity)
      entity.resources.bonus_actions = entity.resources.bonus_actions - 1
      entity.resources.second_wind = entity.resources.second_wind - 1

      entity.hp = math.min(entity:get_max_hp(), entity.hp + (D(10) + entity.level):roll())
    end,
  }
)

fighter.action_surge = {
  codename = "action_surge",
  get_availability = function(self, entity)
    return entity.resources.action_surge > 0
  end,
  _run = function(self, entity)
    entity.resources.action_surge = entity.resources.action_surge - 1
    entity.resources.actions = entity.resources.actions + 1
  end,
}

-- TODO perk.choice.option is of type list<modifier>
--   but should be of type list<list<perk>>
fighter.fighting_style = perk.choice({
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
})

fighter.progression_table = {
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

module_mt.__call = function(_)
  return Tablex.extend(class.mixin(), {
    hp_die = 10,
    save_proficiencies = Common.set({"strength", "constitution"}),

    progression_table = fighter.progression_table,
  })
end

return fighter
