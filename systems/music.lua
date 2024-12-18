local music, _, static = Module("systems.music")

music.system = static .. Tiny.system {
  codename = "sound",
  base_callback = "update",
  update = function(self, dt)
    State.ambient:update()
  end
}

return music
