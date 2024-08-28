local gui = require("tech.gui")
local hostility = require("mech.hostility")
local translation = require("tech.translation")
local interactive = require("tech.interactive")
local sound = require("tech.sound")
local actions = require("mech.creature.actions")


local COLOR = {
  ORDER = Common.hex_color("f7e5b2"),
  NOTIFICATION = Colors.white,
  INACTIVE = Colors.gray,
  HOSTILE = Colors.red,
}

local value_translations = {
  [true] = "да",
  [false] = "нет",
}

return Module("state.gui.sidebar", function()
  return {
    action_entities = {},
    hp_bar = nil,
    hp_text = nil,
    notification = nil,

    last_mode = nil,
    hovered_icon = nil,

    ACTION_GRID_W = 5,
    W = 320,

    order_sound = sound.multiple("assets/sounds/electricity.wav", 0.08)[1],
    notification_sound = sound.multiple("assets/sounds/notification.mp3", 0.01)[1],

    update_indicators = function(self, dt)
      self:_update_hp_bar()
      self:_update_notifications(dt)
      if self.last_mode ~= State:get_mode() then
        self:refresh_action_grid()
        self.last_mode = State:get_mode()
      end
    end,

    _update_hp_bar = function(self)
      local text = "%s/%s" % {State.player.hp, State.player:get_max_hp()}
      local font = self.hp_text.sprite.font

      local hp_bar = self.hp_bar
      local hp_bar_view = State.gui.views[hp_bar.view]
      self.hp_text.sprite.text = text
      self.hp_text.position = hp_bar.position * hp_bar_view:get_multiplier() + Vector({
        (hp_bar.sprite.image:getWidth() * hp_bar_view:get_multiplier() - font:getWidth(text)) / 2,
        2
      })

      hp_bar.sprite.quad = love.graphics.newQuad(
        0, 0,
        hp_bar.sprite.image:getWidth() * math.min(1, State.player.hp / State.player:get_max_hp()),
        hp_bar.sprite.image:getHeight(),
        hp_bar.sprite.image:getDimensions()
      )
    end,

    _update_notifications = function(self, dt)
      self._notification_lifetime = self._notification_lifetime - dt
      if self._notification_lifetime > 0 then return end

      local text, is_order = unpack(table.remove(self._notification_queue, 1) or {})
      if not text then
        self.notification.sprite.text = ""
        return
      end

      self._notification_lifetime = 7
      if is_order then
        State.audio:play_static(self.order_sound)
        self.notification_fx:animate("order")
      else
        State.audio:play_static(self.notification_sound)
        self.notification_fx:animate("normal")
      end

      self.notification.sprite.text = {is_order and COLOR.ORDER or COLOR.NOTIFICATION, text}
    end,

    create_gui_entities = function(self)
      State:add(gui.gui_background())
      self.hp_bar = State:add(gui.hp_bar())
      self.hp_text = State:add(gui.hp_text())
      self.notification = State:add(gui.notification())
      self.notification_fx = State:add(gui.notification_fx())
      self:refresh_action_grid()
    end,

    refresh_action_grid = function(self)
      State:remove_multiple(self.action_entities)
      self.action_entities = State:add_multiple(OrderedMap.iter(State.hotkeys[State:get_mode()])
        :filter(function(key, data) return data.codename and not -Query(data).hidden() end)
        :enumerate()
        :map(function(i, key, data)
          local frame = gui.action_frame(i)
          return {
            gui.action_icon(data, i, frame),
            frame,
            gui.action_hotkey(key, i),
          }
        end)
        :reduce(Table.concat, {})
      )
    end,

    _notification_queue = {},
    _notification_lifetime = 0,

    push_notification = function(self, text, is_order)
      table.insert(self._notification_queue, {text, is_order})
    end,

    clear_notifications = function(self)
      self._notification_queue = {}
      self._notification_lifetime = 0
    end,

    hint_override = nil,

    get_hint = function(self)
      if self.hint_override then return self.hint_override end
      if not Table.contains({"free", "fight"}, State:get_mode()) then return "" end
      local interaction = interactive.get_for(State.player)
      if interaction then
        return "[E] для взаимодействия с " .. Common.get_name(interaction)
      end
      return ""
    end,

    get_text = function(self)
      local result = {}

      local append = function(content)
        if type(content) == "string" then
          content = {content}
        end
        if #result > 0
          and type(result[#result]) == "string"
          and type(content[1]) == "string"
        then
          result[#result] = result[#result] .. content[1]
          table.remove(content, 1)
        end
        Table.concat(result, content)
      end

      local main_weapon = -Query(State.player).inventory.main_hand
      if main_weapon then
        append("Оружие: %s (%s)\n\n" % {
          main_weapon.name,
          actions.get_melee_damage_roll(State.player, "main_hand")
        })
      end

      local second_weapon = -Query(State.player).inventory.other_hand
      if second_weapon then
        append("Второе оружие: %s (%s)\n\n" % {
          second_weapon.name,
          actions.get_melee_damage_roll(State.player, "other_hand")
        })
      end

      local max = Table.extend({},
        State.player:get_resources("move"),
        State.player:get_resources("short"),
        State.player:get_resources("long")
      )

      do
        local table_render = Common.build_table(
          {"", ""},
          OrderedMap.iter(State.player.resources)
            :map(function(k, v)
              return {
                translation.resources[k] or k,
                (value_translations[v] or tostring(v))
                  .. (max[k] == nil
                    and ""
                    or "/" .. (value_translations[max[k]] or tostring(max[k])))
              }
            end)
            :totable()
        ) / "\n"

        append("Ресурсы\n")
        append(table_render[2])

        local highlighted = -Query(self.hovered_icon).hotkey_data.action.cost or {}

        local i = 3
        for k, v in Pairs(State.player.resources) do
          local color = Colors.white
          if highlighted[k] then
            if highlighted[k] > v then
              color = Colors.red
            else
              color = Colors.light_green
            end
          end
          append({
            color,
            "\n" .. table_render[i],
          })
          i = i + 1
        end
      end

      if State.combat then
        append("\n\nОчередь ходов:")
        append(
          State.combat:iter_entities_only()
            :map(function(e)
              return {
                hostility.are_hostile(State.player, e) and COLOR.HOSTILE or Colors.white,
                "\n%s %s" % {
                  State.combat:get_current() == e and "x" or "-",
                  Common.get_name(e),
                },
              }
            end)
            :reduce(Table.concat, {})
        )
      end

      return result
    end,
  }
end)
