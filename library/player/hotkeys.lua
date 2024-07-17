local actions = require("core.actions")
local turn_order = require("tech.turn_order")


local define_hotkey = function(collection, modes, keys, action)
  for _, m in ipairs(modes) do
    for _, k in ipairs(keys) do
      collection[m][k] = action
    end
  end
end

return function()
  local hotkeys = Fun.iter(State.MODES):map(function(m) return m, {} end):tomap()

  -- normal mode --
  for _, pair in ipairs({
    {{"w"}, "up"},
    {{"a"}, "left"},
    {{"s"}, "down"},
    {{"d"}, "right"},
  }) do
    define_hotkey(hotkeys, {"free", "fight"}, pair[1], actions.move[pair[2]])
  end

  define_hotkey(hotkeys, {"fight"}, {"space"}, function() return turn_order.TURN_END_SIGNAL end)

  define_hotkey(hotkeys, {"free", "fight"}, {"1"}, function(entity)
    actions.hand_attack(entity)
  end)

  define_hotkey(hotkeys, {"free", "fight"}, {"3"}, actions.second_wind)
  define_hotkey(hotkeys, {"fight"}, {"4"}, actions.action_surge)

  define_hotkey(hotkeys, {"free", "fight"}, {"e"}, actions.interact)

  define_hotkey(hotkeys, {"free", "fight"}, {"k"}, function(entity)
    State.gui.wiki:show("lorem")
  end)

  define_hotkey(hotkeys, {"fight"}, {"z"}, function(entity)
    actions.dash(entity)
  end)

  -- reading --
  define_hotkey(hotkeys, {"reading"}, {"escape"}, function() State.gui.wiki:exit() end)
  define_hotkey(hotkeys, {"reading"}, {"left"}, function() State.gui.wiki:move_in_history(-1) end)
  define_hotkey(hotkeys, {"reading"}, {"right"}, function() State.gui.wiki:move_in_history(1) end)

  -- dialogue --
  define_hotkey(hotkeys, {"dialogue"}, {"space"}, function() State.gui.dialogue:skip() end)

  -- dialogue options --
  define_hotkey(hotkeys, {"dialogue_options"}, {"w", "up"}, function(entity)
    State.gui.dialogue.selected_option_i = math.max(
      1, (State.gui.dialogue.selected_option_i) - 1
    )
    State.gui.dialogue:options_refresh()
  end)

  define_hotkey(hotkeys, {"dialogue_options"}, {"s", "down"}, function(entity)
    State.gui.dialogue.selected_option_i = math.min(
      #State.gui.dialogue.options, (State.gui.dialogue.selected_option_i) + 1
    )
    State.gui.dialogue:options_refresh()
  end)

  define_hotkey(hotkeys, {"dialogue_options"}, {"e", "return"}, function(entity)
    State.gui.dialogue:options_select()
  end)

  Fun.range(1, 9):each(function(i)
    define_hotkey(hotkeys, {"dialogue_options"}, {tostring(i)}, function(entity)
      if i <= #State.gui.dialogue.options then
        State.gui.dialogue.selected_option_i = i
        State.gui.dialogue:options_select()
      end
    end)
  end)

  -- death --
  define_hotkey(hotkeys, {"death"}, {"return", "e"}, function(entity)
    love.reload_flag = true
  end)

  -- universal --
  define_hotkey(hotkeys, Tablex.deep_copy(State.MODES), {"S-q"}, function()
    if State.debug_mode then love.event.push("quit") end
  end)

  return hotkeys
end
