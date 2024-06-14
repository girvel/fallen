local actions = require("core.actions")
local mech = require("core.mech")
local classes = require("core.classes")
local animated = require("tech.animated")
local creature = require("core.creature")
local interactive = require("tech.interactive")


local module_mt = {}
local module = setmetatable({}, module_mt)

local hotkeys = {
  w = actions.move("up"),
  a = actions.move("left"),
  s = actions.move("down"),
  d = actions.move("right"),

  space = function()
    return true
  end,

  ["1"] = function(entity, state)
    actions.hand_attack(entity, state, state.grids.solids[entity.position + Vector[entity.direction]])
  end,

  ["5"] = function(entity, state)
    actions.sneak_attack(entity, state, state.grids.solids[entity.position + Vector[entity.direction]])
  end,

  ["3"] = function(entity, state)
    if entity.turn_resources.bonus_actions <= 0 then return end
    entity.turn_resources.bonus_actions = entity.turn_resources.bonus_actions - 1

    Fun.iter(pairs(state.grids.solids._inner_array))
      :filter(function(e)
        return e and e.hp and e ~= entity and (e.position - entity.position):abs() <= 3
      end)
      :each(function(e)
        mech.damage(e, state, 1, false)
      end)
  end,

  ["4"] = function(entity)
    actions.aim(entity)
  end,

  e = function(entity, state)
    -- TODO action
    if entity.turn_resources.bonus_actions <= 0 then return end
    local entity_to_interact = interactive.get_for(entity, state)
    if not entity_to_interact then return end
    entity.turn_resources.bonus_actions = entity.turn_resources.bonus_actions - 1
    entity_to_interact:interact(entity, state)
  end,

  z = function(entity, state)
    actions.dash(entity)
  end,

  escape = function(entity)
    if entity.reads then
      entity.reads = nil
      return
    end
  end,
}

local player_character_pack = animated.load_pack("assets/sprites/player_character")

module_mt.__call = function()
  local result = creature(player_character_pack, {
    name = "игрок",
    class = classes.rogue,
    level = 1,
    direction = "right",
    ai = function(self, state)
      local action = hotkeys[self.last_pressed_key]
      self.last_pressed_key = nil
      if action ~= nil then return action(self, state) end
    end,
    abilities = {
      strength = 8,
      dexterity = 18,
      constitution = 14,
      intelligence = 12,
      wisdom = 12,
      charisma = 11,
    },
    reads = nil,
  })

  result.inventory.main_hand = {
    name = "кинжал",
    damage_roll = D(4),
    is_finesse = true,
    bonus = 0,
  }

  return result
end

return module
