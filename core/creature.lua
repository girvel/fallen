local animated = require("tech.animated")
local constants = require("core.constants")
local actions = require("core.actions")
local core = require("core")


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

    rotate = function(self, direction_name)
      self.direction = direction_name
      Fun.iter(self.inventory or {})
        :each(function(_, e) e.direction = direction_name end)
    end,

    get_armor = function(self)
      return 10 + core.get_modifier(self.abilities.dexterity)
    end,

    get_turn_resources = function()
      return {
        movement = constants.DEFAULT_MOVEMENT_SPEED,
        actions = 1,
        bonus_actions = 1,
        reactions = 1,
        has_advantage = false,
      }
    end,

    get_max_hp = function(self)
      if self.max_hp then return self.max_hp end
      local con_bonus = core.get_modifier(self.abilities.constitution)
      return self.class.hp_die + con_bonus
        + (self.level - 1) * (self.class.hp_die / 2 + 1 + con_bonus)
    end,

    get_actions = function(self)
      return {
        actions.hand_attack,
        actions.second_wind,
      }
    end,
  }, object)

  result.hp = result:get_max_hp()
  result.turn_resources = result:get_turn_resources()
  result:animate("idle")

  result.saving_throws = Fun.iter(result.abilities)
    :map(function(name, value)
      return name, D(20)
        + core.get_modifier(value)
        + ((-Query(result).class.save_proficiencies[name]
          or -Query(result).save_proficiencies[name])
          and 2
          or 0)
    end)
    :tomap()

  local main_hand = -Query(result).inventory.main_hand
  if main_hand then
    main_hand.direction = result.direction
    main_hand:animate()
  end

  return result
end

return module
