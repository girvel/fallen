return Module("systems.timed_death", Tiny.processingSystem({
  codename = "timed_death",
  filter = Tiny.requireAll("life_time"),
  base_callback = "update",
  process = function(_, entity, event)
    local dt = unpack(event)
    entity.life_time = entity.life_time - dt
    if entity.life_time <= 0 then
      State:remove(entity)
    end
  end,
}))
