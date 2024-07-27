return Tiny.system({
  codename = "railing",
  base_callback = "update",
  update = function(_, event)
    if State.rails and State.player then State.rails:update(event) end
  end,
})
