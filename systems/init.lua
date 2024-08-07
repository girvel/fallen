return Module("systems", {
  -- for keypressed/mousepressed order is not guaranteed
  -- love.keypressed systems --
  require("systems.input"),

  -- love.mousepressed systems --
  require("systems.detect_clicks"),

  -- love.update systems --
  require("systems.detect_hover"),
  require("systems.acting"),
  require("systems.animation"),
  require("systems.timed_death"),
  require("systems.drift"),
  require("systems.railing"),
  require("systems.sound"),

  -- love.draw systems --
  require("systems.display"),
})
