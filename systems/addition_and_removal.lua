return Tiny.system({
  base_callback = "update",
  update = function(_, state)
    for _, entity in state.entities_to_add
  end,
})
