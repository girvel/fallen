local turn_order = require("tech.turn_order")


return Tiny.processingSystem({
  codename = "acting",
  filter = Tiny.requireAll("ai"),
  base_callback = "update",

  preProcess = function()
    if State.move_order and #State.move_order.list == 2 then
      Log.info(
        "Fight ends as only %s is left standing"
        % Common.get_name(State.move_order.list[1])
      )
      State.move_order = nil
    end
  end,

  process = function(self, entity, event)
    if not State.move_order then
      entity:ai(event)
      if entity.get_turn_resources then Tablex.extend(entity.turn_resources, entity:get_turn_resources()) end
      return
    end

    local is_world_turn = State.move_order:get_current() == turn_order.WORLD_TURN

    if is_world_turn then
      if Fun.iter(State.move_order.list):any(function(e) return e == entity end)
      then return end
      event = {6}  -- 1 round is 6 seconds
    elseif State.move_order:get_current() ~= entity then return end

    local was_timeout_reached = not entity.player_flag and Common.period(self, entity, 20, event[1])

    if was_timeout_reached then
      Log.warn("%s's turn timed out" % Common.get_name(entity))
    end

    if
      entity:ai(event) == turn_order.TURN_END_SIGNAL and not is_world_turn
      or was_timeout_reached
    then
      Tablex.extend(entity.turn_resources, entity:get_turn_resources())
      State.move_order:move_to_next()
      Log.info("%s's turn" % Common.get_name(State.move_order:get_current()))
    end
  end,

  postProcess = function()
    if -Query(State.move_order):get_current() == turn_order.WORLD_TURN
    then
      State.move_order:move_to_next()
    end
  end,
})
