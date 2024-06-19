return Tiny.system({
  base_callback = "update",
  update = function(_, event)
    if State.rails then State.rails:update(event) end
  end,
})
