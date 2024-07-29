local animated = require("tech.animated")
local constants = require("mech.constants")
local actions = require("mech.creature.actions")
local mech = require("mech")


local module = {}
local module_mt = {}
setmetatable(module, module_mt)

module_mt.__call = function(_, animation_pack, object)
  assert(object.max_hp or object.class)
  local result = Tablex.extend(animated(animation_pack), {
    creature_flag = true,

    sprite = {},
    abilities = {
      strength = 10,
      dexterity = 10,
      constitution = 10,
    },
    direction = "right",
    proficiency_bonus = 2,
    inventory = {},
    layer = "solids",
    view = "scene",

    effects = {},

    get_effect = function(self, name, ...)
      return unpack(Fun.chain(self.effects, {self.feat})
        :map(function(effect) return effect[name] end)
        :filter(Fun.op.truth)
        :reduce(
          function(args, modifier)
            return {modifier(self, unpack(args))}
          end,
          {...}
        )
      )
    end,

    get_armor = function(self)
      return 10 + mech.get_modifier(self.abilities.dexterity)
    end,

    get_resources = function(self, rest_type)
      assert(
        Common.set({"move", "short", "long"})[rest_type],
        [[allowed values for rest_type: "move", "short", "long"]]
      )

      local base
      if rest_type == "move" then
        base = {
          movement = self.race.movement_speed,
          actions = 1,
          bonus_actions = 1,
          reactions = 1,
        }
      elseif rest_type == "short" then
        base = {}
      else
        base = {}
      end

      return Tablex.extend(base, -Query(self.class):get_resources(self.level, rest_type) or {})
    end,

    get_max_hp = function(self)
      if self.max_hp then return self.max_hp end
      local con_bonus = mech.get_modifier(self.abilities.constitution)
      return self.class.hp_die + con_bonus
        + (self.level - 1) * (self.class.hp_die / 2 + 1 + con_bonus)
    end,

    get_actions = function(self)
      return Tablex.concat(
        -Query(self.class):get_actions(self.level) or {},
        actions.list
      )
    end,

    rotate = function(self, direction_name)
      self.direction = direction_name
      self:animate()

      Fun.iter(self.inventory or {}):each(function(slot, item)
        item.direction = direction_name
        item:animate()
      end)
    end,

    act = function(self, action)
      if not action:get_availability(self) then return false end
      return action:_run(self)
    end,
  }, object)

  result.hp = result.hp or result:get_max_hp()

  if result.class then
    result.effects = result.class:get_effects(result.level, result.build)
  end

  result.resources = result.resources
    or Tablex.extend({},
      result:get_resources("move"),
      result:get_resources("short"),
      result:get_resources("long")
    )
  result.potential_actions = result:get_actions()
  result:rotate(result.direction)

  result.saving_throws = Fun.iter(result.abilities)
    :map(function(name, value)
      return name, D(20)
        + mech.get_modifier(value)
        + ((-Query(result).class.save_proficiencies[name]
          or -Query(result).save_proficiencies[name])
          and 2
          or 0)
    end)
    :tomap()

  return result
end

return module
