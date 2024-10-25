local animated = require("tech.animated")
local actions = require("mech.creature.actions")
local abilities = require("mech.abilities")
local sound = require("tech.sound")
local on_tiles = require("library.palette.on_tiles")


local creature, module_mt, static = Module("mech.creature")

local get_all_resources = function(e)
  return Table.extend(OrderedMap {},
    e:get_resources("move"),
    e:get_resources("short"),
    e:get_resources("long")
  )
end

--- @class creature_methods
local creature_methods = {
  get_effect = function(self, name, value, ...)
    local args = {...}
    return Fun.iter(self.perks)
      :filter(function(perk) return perk[name] end)
      :reduce(
        function(v, perk)
          return perk[name](perk, self, v, unpack(args))
        end,
        value
      )
  end,

  get_resources = function(self, rest_type)
    assert(
      Common.set({"free", "move", "short", "long"})[rest_type],
      [[allowed values for rest_type: "free", "move", "short", "long"]]
    )

    local base = OrderedMap {}
    if rest_type == "free" then
      base.movement = self.race.movement_speed
      base.bonus_actions = 1
    elseif rest_type == "move" then
      base.actions = 1
      base.bonus_actions = 1
      base.movement = self.race.movement_speed
      base.reactions = 1
    end

    return self:get_effect("modify_resources", base, rest_type)
  end,

  get_actions = function(self)
    return self:get_effect("modify_actions", Table.extend({}, actions.list))
  end,

  --- @param self creature
  --- @return integer
  get_max_hp = function(self)
    if not self.class then return self.max_hp end
    local con_bonus = self:get_modifier("con")
    return self.class.hp_die + con_bonus
      + (self.level - 1) * (self.class.hp_die / 2 + 1 + con_bonus)
  end,

  get_armor = function(self)
    return self.armor_class or (10 + self:get_modifier("dex"))
  end,

  rotate = function(self, direction_name)
    Fun.iter(self.inventory or {}):chain({self = self}):each(function(slot, item)
      if item.direction == direction_name then return end
      item.direction = direction_name
      Query(item):animate()
    end)
  end,

  act = function(self, action)
    if not action:get_availability(self) then return false end
    local ok, result = Debug.pcall(action.run, action, self)
    if ok then return result end
  end,

  level_up = function(self, changes)
    local old_resources = get_all_resources(self)
    local old_max_hp = self:get_max_hp()

    Table.extend(self, changes)

    self.effect_params = Fun.iter(self.perks)
      :map(function(perk) return perk, -Query(perk):initialize_params() or {} end)
      :tomap()
    for k, v in Table.pairs(get_all_resources(self)) do
      self.resources[k] = (self.resources[k] or 0) + v - (old_resources[k] or 0)
    end
    self.potential_actions = self:get_actions()

    self.hp = self.hp + self:get_max_hp() - old_max_hp
  end,

  get_saving_throw = function(self, ability)
    return self:get_effect(
      "modify_saving_throw",
      D(20) + self:get_modifier(ability),
      ability
    )
  end,

  get_modifier = function(self, name)
    if Table.contains(abilities.list, name) then
      return abilities.get_modifier(self:get_effect(
        "modify_ability_score",
        self.base_abilities[name],
        name
      ))
    end

    assert(abilities.skill_bases[name], "%s is not a skill nor an ability" % name)

    return self:get_effect(
      "modify_skill_score",
      self:get_modifier(abilities.skill_bases[name]),
      name
    )
  end,
}

module_mt.__call = function(_, animation_pack, object)
  assert(object.max_hp or object.class, "Creature should either have max_hp or class")

  --- @class creature_base
  local base = {
    creature_flag = true,

    sprite = {},
    base_abilities = abilities(10, 10, 10, 10, 10, 10),
    direction = "right",
    proficiency_bonus = 2,
    inventory = {},
    layer = "solids",
    view = "scene",

    sounds = {
      hit = sound.multiple("assets/sounds/hits_body", 0.3),
    },

    perks = {},

    on_death = function(self)
      if State.grids.items[self.position] then return end
      State:add(on_tiles.blood(), {position = self.position})
    end,
  }

  --- @class creature: creature_methods, creature_base
  local result = Table.extend(
    animated(animation_pack),
    base,
    creature_methods,
    object
  )

  result.hp = result.hp or result:get_max_hp()
  result:rotate(result.direction)
  result.resources = result.resources or get_all_resources(result)
  result:level_up({})

  return result
end

return creature
