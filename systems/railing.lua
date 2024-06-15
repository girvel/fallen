return Tiny.system({
  base_callback = "update",
  update = function(_, state, event)
    if state.rails then state.rails:update(state, event) end
  end,
})
