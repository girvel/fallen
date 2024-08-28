local drift, _, static = Module("systems.drift")

drift.system = static(Tiny.processingSystem({
  codename = "drift",
  filter = Tiny.requireAll("drift"),
  base_callback = "update",
  process = function(_, entity, dt)
    entity.position = entity.position + entity.drift * dt
  end,
}))

return drift
