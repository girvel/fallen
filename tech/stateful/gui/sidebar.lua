local special = require("tech.special")
local interactive = require("tech.interactive")


local order_sound = Common.volumed_sounds("assets/sounds/electricity.wav", 0.08)[1]
local ORDER_COLOR = Common.hex_color("f7e5b2")
local NOTIFICATION_COLOR = Common.hex_color("ededed")
local resource_translations = {
  bonus_actions = "бонусные действия",
  movement = "движение",
  reactions = "реакции",
  actions = "действия",
  has_advantage = "преимущество",
  second_wind = "второе дыхание",
  action_surge = "всплеск действий",
}

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

    update_action_grid = function(self)
      -- State:remove_multiple(self.action_entities)

      -- self.action_entities = Fun.iter(State.player:get_actions())
      --   :enumerate()
      --   :map(function(i, action)
      --     State:add(Tablex.extend({
      --       position = Vector({
      --         (i - 1) % self.ACTION_GRID_W,
      --         math.floor(i / self.ACTION_GRID_W)
      --       }),
      --       view = "actions",
      --     }, action))
      --   end)
      --   :totable()
    end,

    create_gui_entities = function(self)
      State:add(special.gui_background())
      self.hp_bar = State:add(special.hp_bar())
      self.hp_text = State:add(special.hp_text())
      self.notification = State:add(special.notification())
      self.notification_fx = State:add(special.notification_fx())
    end,

    push_notification = function(self, text, is_order)
      if is_order then
        order_sound:play()
        self.notification_fx:animate("order")
      else
        self.notification_fx:animate("normal")
      end

      self.notification.sprite.text = {is_order and ORDER_COLOR or NOTIFICATION_COLOR, text}
      self.notification.position = Vector({
        -15 - self.notification.sprite.font:getWidth(text),
        16 * State.gui.views.sidebar.scale - self.notification.sprite.font:getHeight() / 2
      })
    end,

    end_notification = function(self)
      self.notification.sprite.text = ""
    end,

    get_text = function(self)
      local INACTIVE = Common.hex_color("8b7c99")
      local max = State.player:get_turn_resources()

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

      local weapon = State.player.inventory.main_hand
      if weapon then
        local roll = weapon.damage_roll:to_string()
        if weapon.bonus > 0 then
          roll = roll .. "+" .. weapon.bonus
        end
        append("Оружие: %s (%s)\n\n" % {weapon.name, roll})
      end

      append("Ресурсы:\n" .. table.concat(
        Fun.iter(State.player.turn_resources)
          :map(function(k, v)
            return "  %s: %s%s" % {
              resource_translations[k] or k,
              value_translations[v] or tostring(v),
              max[k] == nil and "" or "/" .. (value_translations[max[k]] or tostring(max[k])),
            }
          end)
          :totable(),
        "\n"
      ))

      append("\n\nДействия:")
      append(
        Fun.iter(State.player.hotkeys[State:get_mode()])
          :group_by(function(key, data) return data, key end)
          :filter(function(data, keys)
            return not data.hidden
              and (not data.action or Tablex.contains(State.player.potential_actions, data.action))
          end)
          :map(function(data, keys)
            return {
              data.action and not data.action:get_availability(State.player) and INACTIVE or {1, 1, 1},
              "\n  [%s] - %s" % {table.concat(keys, "/"), Common.get_name(data)},
            }
          end)
          :reduce(Tablex.concat, {})
      )

      if State.move_order then
        append(
          "\n\nОчередь ходов:\n"
          .. table.concat(
            Fun.iter(State.move_order.list)
              :enumerate()
              :take_n(#State.move_order.list - 1)
              :map(function(i, e) return (State.move_order.current_i == i and "x " or "- ") .. (e.name or "_") end)
              :totable(),
            "\n"
          )
        )
      end

      return result
    end,
  }
end
