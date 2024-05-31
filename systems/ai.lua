return Tiny.processingSystem({
  filter = Tiny.requireAll("ai"),
  base_callback = "update",
  process = function(_, entity, state, event)
    if state.move_order and state.move_order.list[state.move_order.current_i] ~= entity then return end

    if entity:ai(state, event) or not state.move_order then
      entity.turn_resources.movement = 6
      entity.turn_resources.actions = 1
      state.move_order.current_i = state.move_order.current_i + 1
      if state.move_order.current_i > #state.move_order.list then
        state.move_order.current_i = 1
      end
    end
  end,
})
