local special = require("tech.special")
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

local hotkeys_order = Fun.iter(
  ("w a s d up left down right 1 2 3 4 5 6 7 8 9 0 e h return z space k j n "
  .. "Ctrl+enter Shift+q Shift+r") / " "
)
  :enumerate()
  :map(function(i, e) return e, i end)
  :tomap()

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

    ACTION_GRID_W = 5,
    W = 320,

    order_sound = sound.multiple("assets/sounds/electricity.wav", 0.08)[1],
    notification_sound = sound.multiple("assets/sounds/notification.mp3", 0.01)[1],

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
        -- self.notification_fx:animate("order")
      else
        State.audio:play_static(self.notification_sound)
        -- self.notification_fx:animate("normal")
      end

      self.notification.sprite.text = {is_order and COLOR.ORDER or COLOR.NOTIFICATION, text}
      -- self.notification.position = Vector({
      --   -15 - self.notification.sprite.font:getWidth(text),
      --   16 * State.gui.views.sidebar.scale - self.notification.sprite.font:getHeight() / 2
      -- })
    end,

    create_gui_entities = function(self)
      State:add(special.gui_background())
      self.hp_bar = State:add(special.hp_bar())
      self.hp_text = State:add(special.hp_text())
      self.notification = State:add(special.notification())
      -- self.notification_fx = State:add(special.notification_fx())
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
      if not Tablex.contains({"free", "fight"}, State:get_mode()) then return "" end
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
        Tablex.concat(result, content)
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

      if State.player then
        local max = Tablex.extend({},
          State.player:get_resources("move"),
          State.player:get_resources("short"),
          State.player:get_resources("long")
        )

        append(Common.build_table(
          {"Ресурсы", ""},
          Fun.iter(State.player.resources)
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
        ))
      end

      local hotkeys_table = Fun.iter(State.hotkeys[State:get_mode()])
        :filter(function(key, data) return not data.hidden end)
        :map(function(key, data) return {key = key, data = data} end)
        :totable()

      table.sort(hotkeys_table, function(a, b)
        assert(hotkeys_order[a.key], "Hotkey %s is not ordered" % a.key)
        assert(hotkeys_order[b.key], "Hotkey %s is not ordered" % b.key)
        return hotkeys_order[a.key] < hotkeys_order[b.key]
      end)

      append("\n\nУправление\n")
      local render_table = Common.build_table(
        {"", ""},
        Fun.iter(hotkeys_table)
          :map(function(t) return {t.key, Common.get_name(t.data)} end)
          :totable()
      ) / "\n"
      append(render_table[2])

      for i, t in ipairs(hotkeys_table) do
        append({
          t.data.action and not t.data.action:get_availabilities(State.player)
            and COLOR.INACTIVE
            or Colors.white,
          "\n" .. render_table[i + 2]
        })
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
            :reduce(Tablex.concat, {})
        )
      end

      return result
    end,
  }
end)
