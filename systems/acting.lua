local turn_order = require("tech.turn_order")


return Tiny.processingSystem({
  codename = "acting",
  filter = Tiny.requireAll("ai"),
  base_callback = "update",

  preProcess = function()
    if State.move_order and #State.move_order.list == 1 then
      State.move_order = nil
      Log.info(
        "Fight ends as only %s is left standing"
        % Common.get_name(State.move_order.list[1])
      )
    end

    -- TODO optimize
    local solids = State.grids.solids
    for x = 1, solids.size[1] do
      for y = 1, solids.size[2] do
        State.collision_map[y][x] = solids[Vector({x, y})] and 1 or 0
      end
    end
  end,

  process = function(_, entity, event)
    if not State.move_order then
      entity:ai(event)
      if entity.get_turn_resources then Tablex.extend(entity.turn_resources, entity:get_turn_resources()) end
      return
    end

    if State.move_order.list[State.move_order.current_i] ~= entity then return end

    if entity:ai(event) == turn_order.TURN_END_SIGNAL then
      Tablex.extend(entity.turn_resources, entity:get_turn_resources())

      State.move_order.current_i = State.move_order.current_i + 1
      if State.move_order.current_i > #State.move_order.list then
        State.move_order.current_i = 1
      end
    end
  end,
})
