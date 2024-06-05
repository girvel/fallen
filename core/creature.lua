local common = require("utils.common")
local animated = require("tech.animated")
local constants = require("core.constants")


local module = {}
local module_mt = {}
setmetatable(module, module_mt)

module_mt.__call = function(_, animation_pack, object)
  local result = common.extend(animated(animation_pack), {  -- consider moving to mixins and extracting animated
    sprite = {},
    abilities = {
      strength = 10,
      dexterity = 10,
      constitution = 10,
    },
    direction = "right",
    proficiency_bonus = 2,
    inventory = {
      bag = {},
    },
    layer = "solids",

    get_armor = function(self)
      return 10 + module.get_modifier(self.abilities.dexterity)
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
      assert(self.max_hp or self.class)
      if self.max_hp then return self.max_hp end
      local con_bonus = module.get_modifier(self.abilities.constitution)
      return self.class.hp_die + con_bonus
        + (self.level - 1) * (self.class.hp_die / 2 + 1 + con_bonus)
      end,
  }, object or {})

  result.hp = result:get_max_hp()
  result.turn_resources = result:get_turn_resources()
  result:animate("idle")

  return result
end

module.get_modifier = function(ability_score)
  return math.floor((ability_score - 10) / 2)
end

module.are_hostile = function(first, second)
  return first.faction == "monster" or second.faction == "monster" and first.faction ~= second.faction
end

return module
