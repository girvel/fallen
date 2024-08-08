local railing, _, static = Module("systems.railing")

railing.system = static(Tiny.system({
  codename = "railing",
  base_callback = "update",
  update = function(_, event)
    if State.rails and State.player then State.rails:update(event) end
  end,
}))

return railing
