local special = require("tech.special")


local order_sound = Common.volumed_sounds("assets/sounds/electricity.wav", 0.08)[1]
local ORDER_COLOR = Common.hex_color("f7e5b2")
local NOTIFICATION_COLOR = Common.hex_color("ededed")

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
  }
end
