local sound, _, static = Module("systems.sound")

sound.system = static(Tiny.system({
  codename = "ambience",
  base_callback = "update",
  update = function(self, dt)
    State.audio:update()
  end
}))

return sound
