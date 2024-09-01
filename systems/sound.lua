local sound, _, static = Module("systems.sound")

sound.system = static(Tiny.system({
  codename = "sound",
  base_callback = "update",
  update = function(self, dt)
    Log.trace("sound.update()")
    State.audio:update()
    Log.trace("finished updating sound")
  end
}))

return sound
