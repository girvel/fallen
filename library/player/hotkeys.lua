local actions = require("mech.creature.actions")


local define_hotkey = function(collection, modes, keys, data)
  for _, m in ipairs(modes) do
    for _, k in ipairs(keys) do
      collection[m][k] = data
    end
  end
end

return function()
  local hotkeys = Fun.iter(State.MODES):map(function(m) return m, {} end):tomap()

  -- normal mode --
  for _, t in ipairs({
    {{"w"}, "up", "вверх"},
    {{"a"}, "left", "влево"},
    {{"s"}, "down", "вниз"},
    {{"d"}, "right", "вправо"},
  }) do
    local keys, direction_name, direction_translation = unpack(t)
    define_hotkey(hotkeys, {"free", "fight"}, keys, {
      name = "двигаться " .. direction_translation,
      pre_action = function()
        State.player:rotate(direction_name)
      end,
      action = actions.move,
    })
  end

  define_hotkey(hotkeys, {"fight"}, {"space"}, {
    name = "",
    action = actions.finish_turn,
  })

  define_hotkey(hotkeys, {"free", "fight"}, {"1"}, {
    name = "",
    action = actions.hand_attack,
  })

  define_hotkey(hotkeys, {"free", "fight"}, {"3"}, {
    name = "",
    action = actions.second_wind
  })

  define_hotkey(hotkeys, {"fight"}, {"4"}, {
    name = "",
    action = actions.action_surge
  })

  define_hotkey(hotkeys, {"free", "fight"}, {"e"}, {
    name = "",
    action = actions.interact
  })

  define_hotkey(hotkeys, {"fight"}, {"z"}, {
    name = "",
    action = actions.dash
  })

  -- reading --
  define_hotkey(hotkeys, {"reading"}, {"escape"}, {
    name = "",
    pre_action = function() State.gui.wiki:exit() end
  })

  define_hotkey(hotkeys, {"reading"}, {"left"}, {
    name = "",
    pre_action = function() State.gui.wiki:move_in_history(-1) end
  })

  define_hotkey(hotkeys, {"reading"}, {"right"}, {
    name = "",
    pre_action = function() State.gui.wiki:move_in_history(1) end
  })

  -- dialogue --
  define_hotkey(hotkeys, {"dialogue"}, {"space"}, {
    name = "следующая фраза",
    pre_action = function() State.gui.dialogue:skip() end
  })

  -- dialogue options --
  define_hotkey(hotkeys, {"dialogue_options"}, {"w", "up"}, {
    name = "",
    pre_action = function()
      State.gui.dialogue.selected_option_i = math.max(
        1, (State.gui.dialogue.selected_option_i) - 1
      )
      State.gui.dialogue:options_refresh()
    end,
  })

  define_hotkey(hotkeys, {"dialogue_options"}, {"s", "down"}, {
    name = "",
    pre_action = function()
      State.gui.dialogue.selected_option_i = math.min(
        #State.gui.dialogue.options, (State.gui.dialogue.selected_option_i) + 1
      )
      State.gui.dialogue:options_refresh()
    end,
  })

  define_hotkey(hotkeys, {"dialogue_options"}, {"e", "return"}, {
    name = "",
    pre_action = function()
      State.gui.dialogue:options_select()
    end,
  })

  Fun.range(1, 9):each(function(i)
    define_hotkey(hotkeys, {"dialogue_options"}, {tostring(i)}, {
      name = "",
      pre_action = function()
        if i <= #State.gui.dialogue.options then
          State.gui.dialogue.selected_option_i = i
          State.gui.dialogue:options_select()
        end
      end,
    })
  end)

  -- death --
  define_hotkey(hotkeys, {"death"}, {"return", "e"}, {
    name = "",
    pre_action = function()
      love.reload_flag = true
    end,
  })

  -- universal --
  define_hotkey(hotkeys, Tablex.deep_copy(State.MODES), {"S-q"}, {
    name = "завершить игру",
    pre_action = function()
      if State.debug_mode then love.event.push("quit") end
    end,
  })

  define_hotkey(hotkeys, {"free", "fight", "dialogue", "dialogue_options"}, {"k"}, {
    name = "открыть кодекс",
    pre_action = function() State.gui.wiki:show("codex") end,
  })

  return hotkeys
end
