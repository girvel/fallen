return Tiny.processingSystem({
  filter = Tiny.requireAll("drift"),
  base_callback = "update",
  process = function(_, entity, event)
    entity.off_grid_position = entity.off_grid_position + entity.drift * event[1]
  end,
})
