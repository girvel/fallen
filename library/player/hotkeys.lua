local actions = require("mech.creature.actions")
local turn_order = require("tech.turn_order")


local define_hotkey = function(collection, modes, keys, name, run)
  for _, m in ipairs(modes) do
    for _, k in ipairs(keys) do
      collection[m][k] = {name = name, run = run}
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
    define_hotkey(hotkeys, {"free", "fight"}, keys, "двигаться " .. direction_translation, function()
      State.player:rotate(direction_name)
      return actions.move
    end)
  end

  define_hotkey(hotkeys, {"fight"}, {"space"}, "", function() return actions.finish_turn end)

  define_hotkey(hotkeys, {"free", "fight"}, {"1"}, "", function() return actions.hand_attack end)
  define_hotkey(hotkeys, {"free", "fight"}, {"3"}, "", function() return actions.second_wind end)
  define_hotkey(hotkeys, {"fight"}, {"4"}, "", function() return actions.action_surge end)

  define_hotkey(hotkeys, {"free", "fight"}, {"e"}, "", function() return actions.interact end)

  define_hotkey(hotkeys, {"fight"}, {"z"}, "", function() return actions.dash end)

  -- reading --
  define_hotkey(hotkeys, {"reading"}, {"escape"}, "", function() State.gui.wiki:exit() end)
  define_hotkey(hotkeys, {"reading"}, {"left"}, "", function() State.gui.wiki:move_in_history(-1) end)
  define_hotkey(hotkeys, {"reading"}, {"right"}, "", function() State.gui.wiki:move_in_history(1) end)

  -- dialogue --
  define_hotkey(hotkeys, {"dialogue"}, {"space"}, "следующая фраза", function() State.gui.dialogue:skip() end)

  -- dialogue options --
  define_hotkey(hotkeys, {"dialogue_options"}, {"w", "up"}, "", function()
    State.gui.dialogue.selected_option_i = math.max(
      1, (State.gui.dialogue.selected_option_i) - 1
    )
    State.gui.dialogue:options_refresh()
  end)

  define_hotkey(hotkeys, {"dialogue_options"}, {"s", "down"}, "", function()
    State.gui.dialogue.selected_option_i = math.min(
      #State.gui.dialogue.options, (State.gui.dialogue.selected_option_i) + 1
    )
    State.gui.dialogue:options_refresh()
  end)

  define_hotkey(hotkeys, {"dialogue_options"}, {"e", "return"}, "", function(entity)
    State.gui.dialogue:options_select()
  end)

  Fun.range(1, 9):each(function(i)
    define_hotkey(hotkeys, {"dialogue_options"}, {tostring(i)}, "", function(entity)
      if i <= #State.gui.dialogue.options then
        State.gui.dialogue.selected_option_i = i
        State.gui.dialogue:options_select()
      end
    end)
  end)

  -- death --
  define_hotkey(hotkeys, {"death"}, {"return", "e"}, "", function(entity)
    love.reload_flag = true
  end)

  -- universal --
  define_hotkey(hotkeys, Tablex.deep_copy(State.MODES), {"S-q"}, "завершить игру", function()
    if State.debug_mode then love.event.push("quit") end
  end)

  define_hotkey(
    hotkeys, {"free", "fight", "dialogue", "dialogue_options"}, {"k"}, "открыть кодекс",
    function() State.gui.wiki:show("codex") end
  )

  return hotkeys
end
