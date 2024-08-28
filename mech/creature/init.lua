local animated = require("tech.animated")
local actions = require("mech.creature.actions")
local abilities = require("mech.abilities")
local sound = require("tech.sound")


local creature, module_mt, static = Module("mech.creature")

local get_all_resources = function(e)
  return Table.extend(OrderedMap {},
    e:get_resources("move"),
    e:get_resources("short"),
    e:get_resources("long")
  )
end

creature._methods = static {
  get_effect = function(self, name, value, ...)
    local args = {...}
    return Fun.chain(self.effects, {self.feat})
      :map(function(effect) return effect[name] end)
      :filter(Fun.op.truth)
      :reduce(
        function(v, modifier)
          return modifier(self, v, unpack(args))
        end,
        value
      )
  end,

  get_armor = function(self)
    return 10 + abilities.get_modifier(self.abilities.dex)
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

    return Table.extend(base, -Query(self.class):get_resources(self.level, rest_type) or {})
  end,

  get_max_hp = function(self)
    if not self.class then return self.max_hp end
    local con_bonus = abilities.get_modifier(self.abilities.con)
    return self.class.hp_die + con_bonus
      + (self.level - 1) * (self.class.hp_die / 2 + 1 + con_bonus)
  end,

  get_actions = function(self)
    return Table.concat(
      -Query(self.class):get_actions(self.level) or {},
      actions.list
    )
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

    if self.class then
      -- TODO store build perks & feats in one table
      self.effects = self.class:get_effects(self.level, self.build)
      self.perk_params = Fun.iter(self.effects)
        :chain({self.feat})
        :map(function(effect) return effect, {} end)
        :tomap()
    end
    for k, v in Pairs(get_all_resources(self)) do
      self.resources[k] = (self.resources[k] or 0) + v - (old_resources[k] or 0)
    end
    self.hp = self.hp + self:get_max_hp() - old_max_hp
    self.potential_actions = self:get_actions()

    self.saving_throws = Fun.iter(self.abilities)
      :map(function(name, value)
        return name, D(20)
          + abilities.get_modifier(value)
          + ((-Query(self).class.save_proficiencies[name]
            or -Query(self).save_proficiencies[name])
            and 2
            or 0)
      end)
      :tomap()

    self.skill_throws = Fun.iter(abilities.skill_bases)
      :map(function(skill, a)
        return skill, D(20)
          + abilities.get_modifier(self.abilities[a])
          + (-Query(self.skills)[skill] and 2 or 0)
      end)
      :tomap()
  end
}

module_mt.__call = function(_, animation_pack, object)
  assert(object.max_hp or object.class, "Creature should either have max_hp or class")
  local result = Table.extend(animated(animation_pack), {
    creature_flag = true,

    sprite = {},
    abilities = abilities(10, 10, 10, 10, 10, 10),
    direction = "right",
    proficiency_bonus = 2,
    inventory = {},
    layer = "solids",
    view = "scene",

    sounds = {
      hit = sound.multiple("assets/sounds/hits_body", 0.3),
    },

    effects = {},
  }, creature._methods, object)

  result.hp = result.hp or result:get_max_hp()
  result:rotate(result.direction)
  result.resources = result.resources or get_all_resources(result)
  result:level_up({})

  return result
end

return creature
