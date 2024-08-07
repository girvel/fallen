local drift, _, static = Module("systems.drift")

drift.system = static(Tiny.processingSystem({
  codename = "drift",
  filter = Tiny.requireAll("drift"),
  base_callback = "update",
  process = function(_, entity, event)
    entity.position = entity.position + entity.drift * event[1]
  end,
}))

return drift
