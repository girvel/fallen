local railing, _, static = Module("systems.railing")

railing.system = static(Tiny.system({
  codename = "railing",
  base_callback = "update",
  update = function(_, dt)
    if State.rails and State.player then State.rails:update(dt) end
  end,
  postProcess = function(self)
    Log.trace("railing finished")
  end,
}))

return railing
