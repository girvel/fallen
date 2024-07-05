return Tiny.processingSystem({
  filter = Tiny.requireAll("drift"),
  base_callback = "update",
  process = function(_, entity, event)
    entity.gui_position = entity.gui_position + entity.drift * event[1]
  end,
})
