return Tiny.processingSystem({
  filter = Tiny.requireAll("ai"),
  base_callback = "update",
  process = function(_, entity, state, event)
    if not state.move_order or #state.move_order.list <= 1 then
      state.move_order = nil
      entity:ai(state, event)
      entity.turn_resources = entity:get_turn_resources()
      return
    end

    if #state.move_order.list <= 1 then
      state.move_order = nil
      return
    end

    if state.move_order.list[state.move_order.current_i] ~= entity then return end

    if entity:ai(state, event) then
      entity.turn_resources = entity:get_turn_resources()

      state.move_order.current_i = state.move_order.current_i + 1
      if state.move_order.current_i > #state.move_order.list then
        state.move_order.current_i = 1
      end
    end
  end,
})
