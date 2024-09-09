local gui = require("tech.gui")
local sound = require("tech.sound")


local notifier, module_mt, static = Module("state.gui.notifier")

local COLOR = {
  ORDER = Colors.yellow(),
  NOTIFICATION = Colors.white(),
  OLD_ORDER = Colors.dark_yellow(),
  OLD_NOTIFICATION = Colors.gray(),
}

module_mt.__call = function(_)
  return {
    push = function(self, text, is_order)
      table.insert(self._notification_queue, {text, is_order})
    end,

    _notifications = nil,
    _notification_fx = nil,

    _notification_push_id = {},
    _notification_queue = {},

    _order_sound = sound.multiple("assets/sounds/electricity.wav", 0.08),
    _notification_sound = sound.multiple("assets/sounds/notification.mp3", 0.01),

    initialize = function(self)
      self._notifications = Fun.range(3)
        :map(function(i) return State:add(gui.notification(i)) end)
        :totable()
      self._notification_fx = State:add(gui.notification_fx())
    end,

    update = function(self, dt)
      for _, no in ipairs(self._notifications) do
        no.display_time = math.max(0, no.display_time - dt)
        if no.display_time == 0 then
          no.sprite.text = {COLOR.NOTIFICATION, ""}
        end
      end

      if #self._notification_queue > 0 and Common.period(0.5, self._notification_push_id) then
        local text, is_order = unpack(table.remove(self._notification_queue, 1))
        for i = #self._notifications - 1, 1, -1 do
          local from = self._notifications[i]
          local to = self._notifications[i + 1]

          to.sprite.text = from.sprite.text
          to.display_time = from.display_time

          if i == 1 then
            if Table.shallow_same(to.sprite.text[1], COLOR.ORDER) then
              to.sprite.text[1] = COLOR.OLD_ORDER
            else
              to.sprite.text[1] = COLOR.OLD_NOTIFICATION
            end
          end
        end

        self._notifications[1].sprite.text = {is_order and COLOR.ORDER or COLOR.NOTIFICATION, text}
        self._notifications[1].display_time = 7

        if is_order then
          sound.play(self._order_sound)
          self._notification_fx:animate("order")
        else
          sound.play(self._notification_sound)
          self._notification_fx:animate("normal")
        end
      end
    end,
  }
end

return notifier
