local timed_death, _, static = Module("systems.timed_death")

timed_death.system = static(Tiny.processingSystem({
  codename = "timed_death",
  filter = Tiny.requireAll("life_time"),
  base_callback = "update",
  process = function(_, entity, dt)
    entity.life_time = entity.life_time - dt
    if entity.life_time <= 0 then
      State:remove(entity)
    end
  end,
}))

return timed_death
