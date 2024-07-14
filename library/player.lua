local actions = require("core.actions")
local turn_order = require("tech.turn_order")
local classes = require("core.classes")
local humanoid = require("core.humanoid")


local module_mt = {}
local module = setmetatable({}, module_mt)

local define_hotkey = function(collection, modes, keys, action)
  for _, m in ipairs(modes) do
    for _, k in ipairs(keys) do
      collection[m][k] = action
    end
  end
end

local MODES = {"free", "fight", "dialogue", "dialogue_options", "reading"}
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

define_hotkey(hotkeys, {"reading"}, {"left"}, function() State.gui:move_in_wiki_history(-1) end)
define_hotkey(hotkeys, {"reading"}, {"right"}, function() State.gui:move_in_wiki_history(1) end)

define_hotkey(hotkeys, {"free", "fight"}, {"1"}, function(entity)
  actions.hand_attack(entity)
end)

define_hotkey(hotkeys, {"free", "fight"}, {"3"}, actions.second_wind)
define_hotkey(hotkeys, {"fight"}, {"4"}, actions.action_surge)

define_hotkey(hotkeys, {"free", "fight"}, {"e"}, actions.interact)

define_hotkey(hotkeys, {"free", "fight"}, {"k"}, function(entity)
  State.gui:show_page("lorem")
end)

define_hotkey(hotkeys, {"fight"}, {"z"}, function(entity)
  actions.dash(entity)
end)

define_hotkey(hotkeys, Tablex.deep_copy(MODES), {"S-q"}, function()
  if State.debug_mode then love.event.push("quit") end
end)

define_hotkey(hotkeys, {"dialogue_options"}, {"w", "up"}, function(entity)
  entity.dialogue_options.current_i = math.max(1, (entity.dialogue_options.current_i) - 1)
end)

define_hotkey(hotkeys, {"dialogue_options"}, {"s", "down"}, function(entity)
  entity.dialogue_options.current_i = math.min(#entity.dialogue_options, (entity.dialogue_options.current_i) + 1)
end)

define_hotkey(hotkeys, {"dialogue_options"}, {"e", "return"}, function(entity)
  entity.selected_option_i = entity.dialogue_options.current_i
  entity.dialogue_options = nil
end)

Fun.range(1, 9):each(function(i)
  define_hotkey(hotkeys, {"dialogue_options"}, {tostring(i)}, function(entity)
    if i <= #entity.dialogue_options then
      entity.selected_option_i = i
      entity.dialogue_options = nil
    end
  end)
end)

module_mt.__call = function()
  local result = humanoid({
    player_flag = true,
    name = "протагонист",
    class = classes.charming_leader,
    race = {
      codename = "player_character",
      skin_color = Common.hex_color("8ed3dc"),
    },
    level = 2,
    direction = "right",
    immortal = true,
    ai = function(self)
      local mode
      if State.gui.text_entities then
        mode = "reading"
      elseif self.hears then
        mode = "dialogue"
      elseif self.dialogue_options then
        mode = "dialogue_options"
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
      strength = 16,
      dexterity = 18,
      constitution = 14,
      intelligence = 8,
      wisdom = 10,
      charisma = 8,
    },
  })

  result.turn_resources.second_wind = 1
  result.turn_resources.action_surge = 1

  return result
end

return module
