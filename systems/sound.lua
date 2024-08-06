return Static.module("systems.sound", Tiny.system({
  codename = "ambience",
  base_callback = "update",
  update = function(self, event)
    State.audio:update()
  end
}))
