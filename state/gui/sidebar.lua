local special = require("tech.special")
local mech = require("mech")
local translation = require("tech.translation")
local interactive = require("tech.interactive")


local order_sound = Common.volumed_sounds("assets/sounds/electricity.wav", 0.08)[1]

local COLOR = {
  ORDER = Common.hex_color("f7e5b2"),
  NOTIFICATION = Common.hex_color("ededed"),
  INACTIVE = Common.hex_color("8b7c99"),
  HOSTILE = Common.hex_color("e64e4b"),
}

local hotkeys_order = Fun.iter(
  ("w a s d up left down right 1 2 3 4 5 6 7 8 9 0 e h return z space k "
  .. "Ctrl+enter Ctrl+Shift+q Ctrl+Shift+r") / " "
)
  :enumerate()
  :map(function(i, e) return e, i end)
  :tomap()

local value_translations = {
  [true] = "да",
  [false] = "нет",
}

return function()
  return {
    action_entities = {},
    hp_bar = nil,
    hp_text = nil,
    notification = nil,

    ACTION_GRID_W = 5,
    W = 256,

    update_indicators = function(self, dt)
      self:_update_hp_bar()
      self:_update_notifications(dt)
    end,

    _update_hp_bar = function(self)
      if not State.player then
        self.hp_bar.sprite.quad = love.graphics.newQuad(
          0, 0, 0, 0,
          self.hp_bar.sprite.image:getDimensions()
        )
        return
      end

      local text = "%s/%s" % {State.player.hp, State.player:get_max_hp()}
      local font = self.hp_text.sprite.font

      self.hp_text.sprite.text = text
      self.hp_text.position = Vector({
        (self.W - font:getWidth(text)) / 2,
        32 - font:getHeight() / 2
      })

      local hp_bar = self.hp_bar
      hp_bar.sprite.quad = love.graphics.newQuad(
        0, 0,
        hp_bar.sprite.image:getWidth() * State.player.hp / State.player:get_max_hp(),
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
        order_sound:play()
        self.notification_fx:animate("order")
      else
        self.notification_fx:animate("normal")
      end

      self.notification.sprite.text = {is_order and COLOR.ORDER or COLOR.NOTIFICATION, text}
      self.notification.position = Vector({
        -15 - self.notification.sprite.font:getWidth(text),
        16 * State.gui.views.sidebar.scale - self.notification.sprite.font:getHeight() / 2
      })
    end,

    create_gui_entities = function(self)
      State:add(special.gui_background())
      self.hp_bar = State:add(special.hp_bar())
      self.hp_text = State:add(special.hp_text())
      self.notification = State:add(special.notification())
      self.notification_fx = State:add(special.notification_fx())
    end,

    _notification_queue = {},
    _notification_lifetime = 0,

    push_notification = function(self, text, is_order)
      table.insert(self._notification_queue, {text, is_order})
    end,

    get_text = function(self)
      local max = State.player and Tablex.extend({},
        State.player:get_resources("move"),
        State.player:get_resources("short"),
        State.player:get_resources("long")
      ) or nil

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
        Tablex.concat(result, content)
      end

      local main_weapon = -Query(State.player).inventory.main_hand
      if main_weapon then
        local roll = main_weapon.damage_roll:to_string()  -- TODO modify with effects and get_melee_damage_roll
        if main_weapon.bonus > 0 then
          roll = roll .. "+" .. main_weapon.bonus
        end
        append("Оружие: %s (%s)\n\n" % {main_weapon.name, roll})
      end

      local second_weapon = -Query(State.player).inventory.other_hand
      if second_weapon then
        local roll = second_weapon.damage_roll:to_string()  -- TODO modify with effects and get_melee_damage_roll
        if second_weapon.bonus > 0 then
          roll = roll .. "+" .. second_weapon.bonus
        end
        append("Второе оружие: %s (%s)\n\n" % {second_weapon.name, roll})
      end

      if State.player then
        append("Ресурсы:\n" .. table.concat(
          Fun.iter(State.player.resources)
            :map(function(k, v)
              return "  %s: %s%s" % {
                translation.resources[k] or k,
                value_translations[v] or tostring(v),
                max[k] == nil and "" or "/" .. (value_translations[max[k]] or tostring(max[k])),
              }
            end)
            :totable(),
          "\n"
        ))
      end

      append("\n\nДействия:")

      local hotkeys_table = Fun.iter(State.hotkeys[State:get_mode()])
        :group_by(function(key, data) return data, key end)
        :filter(function(data, keys)
          return not data.hidden
            and (not data.action or Tablex.contains(State.player.potential_actions, data.action))
        end)
        :map(function(data, keys)
          table.sort(keys)
          return {data = data, keys = keys}
        end)
        :totable()

      table.sort(hotkeys_table, function(a, b)
        assert(hotkeys_order[a.keys[1]], "Hotkey %s is not ordered" % a.keys[1])
        assert(hotkeys_order[b.keys[1]], "Hotkey %s is not ordered" % b.keys[1])
        return hotkeys_order[a.keys[1]] < hotkeys_order[b.keys[1]]
      end)

      append(
        Fun.iter(hotkeys_table)
          :map(function(t)
            return {
              t.data.action and not t.data.action:get_availability(State.player)
                and COLOR.INACTIVE
                or {1, 1, 1},
              "\n  [%s] - %s" % {table.concat(t.keys, "/"), Common.get_name(t.data)},
            }
          end)
          :reduce(Tablex.concat, {})
      )

      if State.combat then
        append("\n\nОчередь ходов:")
        append(
          State.combat:iter_entities_only()
            :map(function(e)
              return {
                mech.are_hostile(State.player, e) and COLOR.HOSTILE or {1, 1, 1},
                "\n%s %s" % {
                  State.combat:get_current() == e and "x" or "-",
                  Common.get_name(e),
                },
              }
            end)
            :reduce(Tablex.concat, {})
        )
      end

      if State.player then
        local interaction = interactive.get_for(State.player)
        if interaction then
          append("\n\nСмотрит на " .. Common.get_name(interaction))
        end
      end

      return result
    end,
  }
end
