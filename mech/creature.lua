local animated = require("tech.animated")
local constants = require("mech.constants")
local actions = require("mech.actions")
local mech = require("mech")


local module = {}
local module_mt = {}
setmetatable(module, module_mt)

module_mt.__call = function(_, animation_pack, object)
  assert(object.max_hp or object.class)
  local result = Tablex.extend(animated(animation_pack), {  -- TODO consider moving to mixins and extracting animated
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

    get_armor = function(self)
      return 10 + mech.get_modifier(self.abilities.dexterity)
    end,

    get_turn_resources = function()
      return {
        movement = constants.DEFAULT_MOVEMENT_SPEED,
        actions = 1,
        bonus_actions = 1,
        reactions = 1,
      }
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
  }, object)

  result.hp = result.hp or result:get_max_hp()
  result.turn_resources = result.turn_resources or result:get_turn_resources()
  result.available_actions = result:get_actions()
  result:animate("idle")

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

  result:rotate(result.direction)

  return result
end

return module
