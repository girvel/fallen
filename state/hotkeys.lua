local feats = require("mech.feats")
local game_save = require("state.game_save")
local actions = require("mech.creature.actions")
local fighter = require("mech.classes.fighter")
local class = require("mech.class")
local utf8 = require("utf8")


local define_hotkey = function(collection, modes, keys, data)
  for _, m in ipairs(modes) do
    local first = true
    for _, k in ipairs(keys) do
      if first then
        collection[m][k] = data
      else
        collection[m][k] = Table.extend({}, data, {hidden = function() return true end})
      end
      first = false
    end
  end
end

return Module("state.hotkeys", function(modes, debug_mode)
  local hotkeys = Fun.iter(modes):map(function(m) return m, OrderedMap() end):tomap()

  setmetatable(hotkeys, {
    __serialize = function(self)
      return function()
        return require("state.hotkeys")(modes, debug_mode)
      end
    end
  })

  -- normal mode --
  local movement_group = {}
  for _, t in ipairs({
    {{"w"}, "up", "вверх"},
    {{"a"}, "left", "влево"},
    {{"s"}, "down", "вниз"},
    {{"d"}, "right", "вправо"},
  }) do
    local keys, direction_name, direction_translation = unpack(t)
    define_hotkey(hotkeys, {"free", "combat"}, keys, {
      hidden = function() return true end,
      mutex_group = movement_group,
      name = "двигаться " .. direction_translation,
      codename = "move_" .. direction_name,
      pre_action = function()
        State.player:rotate(direction_name)
      end,
      action = actions.move,
    })
  end

  define_hotkey(hotkeys, {"combat"}, {"space"}, {
    name = "закончить ход",
    codename = "finish_turn",
    action = actions.finish_turn,
  })

  define_hotkey(hotkeys, {"free", "combat"}, {"1"}, {
    name = "атака правой",
    codename = "hand_attack",
    action = actions.hand_attack,
  })

  define_hotkey(hotkeys, {"free", "combat"}, {"2"}, {
    name = "атака левой",
    codename = "other_hand_attack",
    action = actions.other_hand_attack,
  })

  define_hotkey(hotkeys, {"free", "combat"}, {"3"}, {
    name = "второе дыхание",
    codename = "second_wind",
    action = fighter.second_wind,
  })

  define_hotkey(hotkeys, {"combat"}, {"4"}, {
    name = "всплеск действий",
    codename = "action_surge",
    action = fighter.action_surge,
  })

  define_hotkey(hotkeys, {"free", "combat"}, {"e"}, {
    name = "взаимодействие",
    codename = "interact",
    action = actions.interact
  })

  define_hotkey(hotkeys, {"free", "combat"}, {"shift"}, {
    name = "рывок",
    codename = "dash",
    action = actions.dash
  })

  define_hotkey(hotkeys, {"free"}, {"h"}, {
    name = "перевязать раны",
    codename = "hit_dice",
    action = class.hit_dice_action,
  })

  define_hotkey(hotkeys, {"free", "combat"}, {"g"}, {
    name = "мастер двуручного оружия",
    codename = "toggle_gwm",
    hidden = function(entity)
      return State.player.feat ~= feats.great_weapon_master
    end,
    pre_action = function()
      if State.player.feat ~= feats.great_weapon_master then return end
      local params = State.player.perk_params[feats.great_weapon_master]
      params.enabled = not params.enabled
    end,
    is_passive_enabled = function()
      return State.player.perk_params[feats.great_weapon_master].enabled
    end,
  })

  -- reading --
  define_hotkey(hotkeys, {"reading"}, {"esc"}, {
    name = "выйти из кодекса",
    codename = "exit",
    pre_action = function() State.gui.wiki:exit() end
  })

  define_hotkey(hotkeys, {"reading"}, {"left"}, {
    name = "назад",
    codename = "left",
    pre_action = function() State.gui.wiki:move_in_history(-1) end
  })

  define_hotkey(hotkeys, {"reading"}, {"right"}, {
    name = "вперёд",
    codename = "right",
    pre_action = function() State.gui.wiki:move_in_history(1) end
  })

  -- dialogue --
  define_hotkey(hotkeys, {"dialogue"}, {"space"}, {
    name = "следующая фраза",
    codename = "next",
    hidden = function() return true end,
    pre_action = function() State.gui.dialogue:skip() end
  })

  -- dialogue options --
  define_hotkey(hotkeys, {"dialogue_options"}, {"w", "up"}, {
    name = "опция выше",
    codename = "up",
    hidden = function() return true end,
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
    codename = "down",
    hidden = function() return true end,
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
    codename = "submit",
    hidden = function() return true end,
    pre_action = function()
      State.gui.dialogue:options_select()
    end,
  })

  Fun.range(1, 9):each(function(i)
    define_hotkey(hotkeys, {"dialogue_options"}, {tostring(i)}, {
      name = "выбрать опцию #" .. i,
      hidden = function() return true end,
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
    name = "начать с последнего сохранения",
    pre_action = function()
      game_save.read()
    end,
  })

  define_hotkey(hotkeys, {"death"}, {"r"}, {
    name = "начать заново",
    pre_action = function()
      love.reload_flag = function() return true end
    end,
  })

  -- character creator --
  for _, t in ipairs({
    {{"w", "up"}, "up", "вверх"},
    {{"a", "left"}, "left", "влево"},
    {{"s", "down"}, "down", "вниз"},
    {{"d", "right"}, "right", "вправо"},
    {{"e", "enter"}, "zero"},
  }) do
    local keys, direction_name, direction_translation = unpack(t)
    define_hotkey(hotkeys, {"character_creator"}, keys, {
      name = direction_translation,
      codename = direction_name,
      pre_action = function()
        State.gui.character_creator:move_cursor(direction_name)
      end,
    })
  end

  define_hotkey(hotkeys, {"character_creator"}, {"enter"}, {
    name = "Создать",
    codename = "submit",
    pre_action = function()
      State.gui.character_creator:submit()
    end,
  })

  define_hotkey(hotkeys, {"character_creator"}, {"esc"}, {
    name = "Закрыть редактор",
    codename = "exit",
    pre_action = function()
      State.gui.character_creator:close()
    end,
  })

  -- text input --
  define_hotkey(hotkeys, {"text_input"}, {"backspace"}, {
    hidden = function() return true end,
    pre_action = function()
      local input = State.gui.text_input
      if #input.text == 0 then return end
      input.text = input.text:sub(1, utf8.offset(input.text, utf8.len(input.text)) - 1)
    end
  })

  define_hotkey(hotkeys, {"text_input"}, {"enter"}, {
    hidden = function() return true end,
    pre_action = function()
      State.gui.text_input.active = false
    end
  })

  -- universal --
  define_hotkey(hotkeys, Table.deep_copy(modes), {"Shift+q"}, {
    name = "завершить игру",
    pre_action = function()
      love.event.push("quit")
    end,
  })

  define_hotkey(hotkeys, Table.deep_copy(modes), {"Shift+r"}, {
    name = "начать заново",
    pre_action = function()
      love.reload_flag = function() return true end
    end,
  })

  define_hotkey(hotkeys, {"free", "combat", "dialogue", "dialogue_options", "reading"}, {"k"}, {
    name = "кодекс",
    codename = "open_codex",
    pre_action = function() State.gui.wiki:show("codex") end,
  })

  define_hotkey(hotkeys, {"free", "combat", "dialogue", "dialogue_options", "reading"}, {"j"}, {
    name = "журнал",
    codename = "open_journal",
    pre_action = function() State.gui.wiki:show_journal() end,
  })

  define_hotkey(hotkeys, {"free", "combat", "dialogue", "dialogue_options", "reading"}, {"n"}, {
    name = "редактор персонажа",
    codename = "open_creator",
    pre_action = function() State.gui.character_creator:refresh() end,
  })

  return hotkeys
end)
