return {
  -- for keypressed/mousepressed order is not guaranteed
  -- love.keypressed systems --
  require("systems.input"),

  -- love.mousepressed systems --
  require("systems.on_click_calls"),

  -- love.update systems --
  require("systems.acting"),
  require("systems.animation"),
  require("systems.timed_death"),
  require("systems.drift"),
  require("systems.railing"),

  -- love.draw systems --
  require("systems.display"),
}
