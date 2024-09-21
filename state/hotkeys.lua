local feats = require("mech.feats")
local actions = require("mech.creature.actions")
local fighter = require("mech.classes.fighter")
local class = require("mech.class")


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

return Module("state.hotkeys", function(modes)
  local hotkeys = Fun.iter(modes):map(function(m) return m, OrderedMap() end):tomap()

  setmetatable(hotkeys, {
    __serialize = function(self)
      return function()
        return require("state.hotkeys")(modes)
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

  local attack_description = function(slot)
    return function(self)
      return Html(function()
        return stats {
          "Атака: ", actions.get_melee_attack_roll(State.player, slot), br(),
          "Урон: ", actions.get_melee_damage_roll(State.player, slot),
        }
      end)
    end
  end

  define_hotkey(hotkeys, {"free", "combat"}, {"1"}, {
    name = "атака правой",
    codename = "hand_attack",
    action = actions.hand_attack,
    get_description = attack_description("main_hand"),
  })

  define_hotkey(hotkeys, {"free", "combat"}, {"2"}, {
    name = "атака левой",
    codename = "other_hand_attack",
    action = actions.other_hand_attack,
    get_description = attack_description("other_hand"),
  })

  local healing_description = function(self)
    return Html(function()
      return stats {
        "Восстанавливает ", self.action:get_healing_roll(State.player), " здоровья"
      }
    end)
  end

  define_hotkey(hotkeys, {"free", "combat"}, {"3"}, {
    name = "второе дыхание",
    codename = "second_wind",
    action = fighter.second_wind.action,
    get_description = healing_description,
  })

  define_hotkey(hotkeys, {"combat"}, {"4"}, {
    name = "всплеск действий",
    codename = "action_surge",
    action = fighter.action_surge.action,
    get_description = function(self)
      return Html(function()
        return stats {
          "+1 действие на один ход",
        }
      end)
    end
  })

  define_hotkey(hotkeys, {"combat"}, {"5"}, {
    name = "боевой дух",
    codename = "fighting_spirit",
    action = fighter.fighting_spirit.action,
    get_description = function(self)
      return Html(function(self)
        return stats {
          "преимущество до конца хода",
        }
      end)
    end
  })

  define_hotkey(hotkeys, {"free", "combat"}, {"e"}, {
    name = "взаимодействие",
    codename = "interact",
    action = actions.interact
  })

  define_hotkey(hotkeys, {"free", "combat"}, {"shift"}, {
    name = "рывок",
    codename = "dash",
    action = actions.dash,
    get_description = function(self)
      return Html(function()
        return stats {
          "+", self.action:get_movement_bonus(State.player), " к скорости движения",
        }
      end)
    end,
  })

  define_hotkey(hotkeys, {"combat"}, {"z"}, {
    name = "отход",
    codename = "disengage",
    action = actions.disengage,
    get_description = function(self)
      return Html(function()
        return stats {"Не провоцировать атаки при движении"}
      end)
    end
  })

  define_hotkey(hotkeys, {"free"}, {"h"}, {
    name = "перевязать раны",
    codename = "hit_dice",
    action = class.hit_dice.action,
    get_description = healing_description,
  })

  define_hotkey(hotkeys, {"free", "combat"}, {"g"}, {
    name = "мастер двуручного оружия",
    codename = "toggle_gwm",
    _perk = feats.great_weapon_master,
    get_description = function(self)
      return Html(function()
        return stats {
          "%+i" % self._perk.attack_modifier, " к атаке", br(),
          "%+i" % self._perk.damage_modifier, " к урону", br(),
          "Двуручное или полуторное оружие"
        }
      end)
    end,
    hidden = function(self)
      return not Table.contains(State.player.perks, self._perk)
    end,
    pre_action = function(self)
      if self:hidden() then return end
      local params = State.player.effect_params[self._perk]
      params.enabled = not params.enabled
    end,
    is_passive_enabled = function(self)
      return State.player.effect_params[self._perk].enabled
    end,
  })

  -- reading --
  define_hotkey(hotkeys, {"reading"}, {"esc"}, {
    name = "выйти из кодекса",
    codename = "exit",
    pre_action = function() State.gui.wiki:exit() end
  })

  define_hotkey(hotkeys, {"reading"}, {"left", "rmb", "backmb"}, {
    name = "назад",
    codename = "left",
    pre_action = function() State.gui.wiki:move_in_history(-1) end
  })

  define_hotkey(hotkeys, {"reading"}, {"right", "forwardmb"}, {
    name = "вперёд",
    codename = "right",
    pre_action = function() State.gui.wiki:move_in_history(1) end
  })

  -- dialogue --
  define_hotkey(hotkeys, {"dialogue"}, {"space", "lmb"}, {
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
      love.custom.load("last.fallen_save")
    end,
  })

  define_hotkey(hotkeys, {"death"}, {"r"}, {
    name = "начать заново",
    pre_action = function()
      love.custom.load("start.fallen_save")
    end,
  })

  -- character creator --
  for _, t in ipairs({
    {{"w", "up"}, "up", "вверх"},
    {{"s", "down"}, "down", "вниз"},
    {{"a", "left"}, "left", "влево"},
    {{"d", "right"}, "right", "вправо"},
    {{"e", "enter"}, "zero"},
  }) do
    local keys, direction_name, direction_translation = unpack(t)
    define_hotkey(hotkeys, {"character_creator"}, keys, {
      name = direction_translation,
      codename = direction_name,
      pre_action = function()
        State.gui.creator:move_cursor(Vector[direction_name])
      end,
    })
  end

  define_hotkey(hotkeys, {"character_creator"}, {"enter"}, {
    name = "Создать",
    codename = "submit",
    pre_action = function()
      State.gui.creator:submit()
    end,
    get_availability = function()
      return State.gui.creator:can_submit()
    end,
  })

  define_hotkey(hotkeys, {"character_creator"}, {"esc"}, {
    name = "Закрыть редактор",
    codename = "exit",
    pre_action = function()
      State.gui.creator:close()
    end,
    get_availability = function()
      return State.gui.creator:can_close()
    end,
  })

  -- text input --
  define_hotkey(hotkeys, {"text_input"}, {"backspace"}, {
    hidden = function() return true end,
    pre_action = function()
      local input = State.gui.text_input
      if #input.text == 0 or input.text:utf_len() > 100 then return end
      input.text = input.text:utf_sub(1, -2)
    end
  })

  define_hotkey(hotkeys, {"text_input"}, {"enter"}, {
    hidden = function() return true end,
    pre_action = function()
      if State.gui.text_input.text:find("^%s*$") then return end
      State.gui.text_input.active = false
    end
  })

  -- universal --
  define_hotkey(hotkeys, Table.deep_copy(modes), {"Ctrl+d"}, {
    name = "завершить игру",
    pre_action = function()
      love.event.push("quit")
    end,
  })

  define_hotkey(hotkeys, Table.deep_copy(modes), {"Ctrl+r"}, {
    name = "начать заново",
    pre_action = function()
      love.custom.load("start.fallen_save")
    end,
  })

  if Debug.debug_mode then
    define_hotkey(hotkeys, Table.deep_copy(modes), {"Ctrl+s"}, {
      name = "загрузить сохранение",
      pre_action = function()
        love.custom.load("last.fallen_save")
      end
    })
  end

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
    pre_action = function() State.gui.creator:refresh() end,
  })

  return hotkeys
end)
