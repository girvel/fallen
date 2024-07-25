local special = require("tech.special")
local mech = require("mech")


local order_sound = Common.volumed_sounds("assets/sounds/electricity.wav", 0.08)[1]

local COLOR = {
  ORDER = Common.hex_color("f7e5b2"),
  NOTIFICATION = Common.hex_color("ededed"),
  INACTIVE = Common.hex_color("8b7c99"),
  HOSTILE = Common.hex_color("e64e4b"),
}

local resource_translations = {
  bonus_actions = "бонусные действия",
  movement = "движение",
  reactions = "реакции",
  actions = "действия",
  second_wind = "второе дыхание",
  action_surge = "всплеск действий",
}

local hotkeys_order = Fun.iter(
  "w a s d up left down right 1 2 3 4 5 6 7 8 9 0 e return z space k Shift+q" / " "
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

    update_indicators = function(self)
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

      self.notification.sprite.text = {is_order and COLOR.ORDER or COLOR.NOTIFICATION, text}
      self.notification.position = Vector({
        -15 - self.notification.sprite.font:getWidth(text),
        16 * State.gui.views.sidebar.scale - self.notification.sprite.font:getHeight() / 2
      })
    end,

    end_notification = function(self)
      self.notification.sprite.text = ""
    end,

    get_text = function(self)
      local max = Tablex.extend({},
        State.player:get_resources("move"),
        State.player:get_resources("short"),
        State.player:get_resources("long")
      )

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
        Fun.iter(State.player.resources)
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

      local hotkeys_table = Fun.iter(State.player.hotkeys[State:get_mode()])
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

      return result
    end,
  }
end
