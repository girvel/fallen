local actions = require("mech.creature.actions")
local fighter = require("mech.classes.fighter")
local class = require("mech.class")


local define_hotkey = function(collection, modes, keys, data)
  for _, m in ipairs(modes) do
    for _, k in ipairs(keys) do
      collection[m][k] = data
    end
  end
end

return function(modes, debug_mode)
  local hotkeys = Fun.iter(modes):map(function(m) return m, {} end):tomap()

  -- normal mode --
  for _, t in ipairs({
    {{"w"}, "up", "вверх"},
    {{"a"}, "left", "влево"},
    {{"s"}, "down", "вниз"},
    {{"d"}, "right", "вправо"},
  }) do
    local keys, direction_name, direction_translation = unpack(t)
    define_hotkey(hotkeys, {"free", "combat"}, keys, {
      name = "двигаться " .. direction_translation,
      pre_action = function()
        State.player:rotate(direction_name)
      end,
      action = actions.move,
    })
  end

  define_hotkey(hotkeys, {"combat"}, {"space"}, {
    name = "закончить ход",
    action = actions.finish_turn,
  })

  define_hotkey(hotkeys, {"free", "combat"}, {"1"}, {
    name = "атака основной рукой",
    action = actions.hand_attack,
  })

  define_hotkey(hotkeys, {"free", "combat"}, {"2"}, {
    name = "атака второй рукой",
    action = actions.other_hand_attack,
  })

  define_hotkey(hotkeys, {"free", "combat"}, {"3"}, {
    name = "второе дыхание",
    action = fighter.second_wind,
  })

  define_hotkey(hotkeys, {"combat"}, {"4"}, {
    name = "всплеск действий",
    action = fighter.action_surge,
  })

  define_hotkey(hotkeys, {"free", "combat"}, {"e"}, {
    name = "взаимодействие",
    action = actions.interact
  })

  define_hotkey(hotkeys, {"combat"}, {"z"}, {
    name = "рывок",
    action = actions.dash
  })

  define_hotkey(hotkeys, {"free"}, {"h"}, {
    name = "перевязать раны",
    action = class.hit_dice_action,
  })

  -- reading --
  define_hotkey(hotkeys, {"reading"}, {"escape"}, {
    name = "выйти из кодекса",
    pre_action = function() State.gui.wiki:exit() end
  })

  define_hotkey(hotkeys, {"reading"}, {"left"}, {
    name = "назад",
    pre_action = function() State.gui.wiki:move_in_history(-1) end
  })

  define_hotkey(hotkeys, {"reading"}, {"right"}, {
    name = "вперёд",
    pre_action = function() State.gui.wiki:move_in_history(1) end
  })

  -- dialogue --
  define_hotkey(hotkeys, {"dialogue"}, {"space"}, {
    name = "следующая фраза",
    pre_action = function() State.gui.dialogue:skip() end
  })

  -- dialogue options --
  define_hotkey(hotkeys, {"dialogue_options"}, {"w", "up"}, {
    name = "опция выше",
    pre_action = function()
      State.gui.dialogue.selected_option_i = Common.loop(
        State.gui.dialogue.selected_option_i - 1,
        #State.gui.dialogue.options
      )
      State.gui.dialogue:options_refresh()
    end,
  })

  define_hotkey(hotkeys, {"dialogue_options"}, {"s", "down"}, {
    name = "опция ниже",
    pre_action = function()
      State.gui.dialogue.selected_option_i = Common.loop(
        State.gui.dialogue.selected_option_i + 1,
        #State.gui.dialogue.options
      )
      State.gui.dialogue:options_refresh()
    end,
  })

  define_hotkey(hotkeys, {"dialogue_options"}, {"e", "enter"}, {
    name = "выбрать опцию",
    pre_action = function()
      State.gui.dialogue:options_select()
    end,
  })

  Fun.range(1, 9):each(function(i)
    define_hotkey(hotkeys, {"dialogue_options"}, {tostring(i)}, {
      name = "выбрать опцию #" .. i,
      hidden = true,
      pre_action = function()
        if i <= #State.gui.dialogue.options then
          State.gui.dialogue.selected_option_i = i
          State.gui.dialogue:options_select()
        end
      end,
    })
  end)

  -- death --
  define_hotkey(hotkeys, {"death"}, {"enter", "e"}, {
    name = "начать заново",
    pre_action = function()
      love.reload_flag = true
    end,
  })

  -- character creator --
  for _, t in ipairs({
    {{"w", "up"}, "up", "вверх"},
    {{"a", "left"}, "left", "влево"},
    {{"s", "down"}, "down", "вниз"},
    {{"d", "right"}, "right", "вправо"},
  }) do
    local keys, direction_name, direction_translation = unpack(t)
    define_hotkey(hotkeys, {"character_creator"}, keys, {
      name = direction_translation,
      pre_action = function()
        State.gui.character_creator:move_cursor(direction_name)
      end,
    })
  end

  define_hotkey(hotkeys, {"character_creator"}, {"Ctrl+enter"}, {
    name = "Создать персонажа",
    pre_action = function()
      State.gui.character_creator:submit()
    end,
  })

  -- universal --
  define_hotkey(hotkeys, Tablex.deep_copy(modes), {"Ctrl+Shift+q", debug_mode and "Shift+q" or nil}, {
    name = "завершить игру",
    pre_action = function()
      love.event.push("quit")
    end,
  })

  define_hotkey(hotkeys, Tablex.deep_copy(modes), {"Ctrl+Shift+r"}, {
    name = "начать заново",
    pre_action = function()
      love.reload_flag = true
    end,
  })

  define_hotkey(hotkeys, {"free", "combat", "dialogue", "dialogue_options"}, {"k"}, {
    name = "открыть кодекс",
    pre_action = function() State.gui.wiki:show("dreamers") end,  -- TODO RM
  })

  return hotkeys
end
