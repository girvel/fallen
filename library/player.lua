local actions = require("core.actions")
local turn_order = require("tech.turn_order")
local classes = require("core.classes")
local animated = require("tech.animated")
local creature = require("core.creature")
local interactive = require("tech.interactive")
local weapons = require("library.weapons")


local module_mt = {}
local module = setmetatable({}, module_mt)

local define_hotkey = function(collection, modes, keys, action)
  for _, m in ipairs(modes) do
    for _, k in ipairs(keys) do
      collection[m][k] = action
    end
  end
end

local MODES = {"free", "fight", "dialogue", "reading"}
local hotkeys = Fun.iter(MODES):map(function(m) return m, {} end):tomap()

for _, pair in ipairs({
  {{"w"}, "up"},
  {{"a"}, "left"},
  {{"s"}, "down"},
  {{"d"}, "right"},
}) do
  define_hotkey(hotkeys, {"free", "fight"}, pair[1], actions.move[pair[2]])
end

define_hotkey(hotkeys, {"fight"}, {"space"}, function() return turn_order.TURN_END_SIGNAL end)
define_hotkey(hotkeys, {"dialogue"}, {"space"}, function(entity) entity.hears = nil end)
define_hotkey(hotkeys, {"reading"}, {"escape"}, function() State.gui:exit_wiki() end)

define_hotkey(hotkeys, {"free", "fight"}, {"1"}, function(entity)
  actions.hand_attack(entity, State.grids.solids[entity.position + Vector[entity.direction]])
end)

define_hotkey(hotkeys, {"free", "fight"}, {"3"}, actions.second_wind)
define_hotkey(hotkeys, {"fight"}, {"4"}, actions.action_surge)

define_hotkey(hotkeys, {"free", "fight"}, {"e"}, function(entity)
  -- TODO action
  if entity.turn_resources.bonus_actions <= 0 then return end
  local entity_to_interact = interactive.get_for(entity)
  if not entity_to_interact then return end
  entity.turn_resources.bonus_actions = entity.turn_resources.bonus_actions - 1
  entity_to_interact:interact(entity)
end)

define_hotkey(hotkeys, {"free", "fight"}, {"k"}, function(entity)
  State.gui:show_page("lorem")
end)

define_hotkey(hotkeys, {"fight"}, {"z"}, function(entity)
  actions.dash(entity)
end)

local player_character_pack = animated.load_pack("assets/sprites/player_character")

module_mt.__call = function()
  local result = creature(player_character_pack, {
    player_flag = true,
    name = "протагонист",
    class = classes.charming_leader,
    level = 2,
    direction = "right",
    immortal = true,
    ai = function(self)
      local mode
      if State.gui.text_entities then
        mode = "reading"
      elseif self.hears then
        mode = "dialogue"
      elseif State.move_order then
        mode = "fight"
      else
        mode = "free"
      end

      local action = hotkeys[mode][self.last_pressed_key]
      self.last_pressed_key = nil
      if action ~= nil then return action(self) end
    end,
    abilities = {
      strength = 8,
      dexterity = 18,
      constitution = 14,
      intelligence = 12,
      wisdom = 12,
      charisma = 11,
    },
  })

  result.inventory.main_hand = weapons.rapier()

  result.turn_resources.second_wind = 1
  result.turn_resources.action_surge = 1

  return result
end

return module
