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

  process = function(_, entity, event)
    if not State.move_order then
      entity:ai(event)
      if entity.get_turn_resources then Tablex.extend(entity.turn_resources, entity:get_turn_resources()) end
      return
    end

    local is_world_turn = State.move_order.current_i == #State.move_order.list

    if is_world_turn then
      if Fun.iter(State.move_order.list)
        :any(function(e) return e == entity end)
      then return end
      event = {6}  -- 1 round is 6 seconds
    elseif State.move_order.list[State.move_order.current_i] ~= entity then return end

    if entity:ai(event) == turn_order.TURN_END_SIGNAL and not is_world_turn then
      Tablex.extend(entity.turn_resources, entity:get_turn_resources())

      State.move_order.current_i = State.move_order.current_i + 1
      if State.move_order.current_i > #State.move_order.list then
        State.move_order.current_i = 1
      end
    end
  end,

  postProcess = function()
    if State.move_order and State.move_order.current_i == #State.move_order.list then
      State.move_order.current_i = 1
    end
  end,
})
