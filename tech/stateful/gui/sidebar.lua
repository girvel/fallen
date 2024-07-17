local special = require("tech.special")


return function()
  return {
    action_entities = {},
    hp_bar = nil,
    hp_text = nil,
    notification = nil,

    ACTION_GRID_W = 5,

    update_action_grid = function(self)
      State:remove_multiple(self.action_entities)

      self.action_entities = Fun.iter(State.player:get_actions())
        :enumerate()
        :map(function(i, action)
          State:add(Tablex.extend({
            position = Vector({
              (i - 1) % self.ACTION_GRID_W,
              math.floor(i / self.ACTION_GRID_W)
            }),
            view = "actions",
          }, action))
        end)
        :totable()
    end,

    create_gui_entities = function(self)
      State:add(special.gui_background())
      self.hp_bar = State:add(special.hp_bar())
      self.hp_text = State:add(special.hp_text())
      self.notification = State:add(special.notification())
    end,
  }
end
