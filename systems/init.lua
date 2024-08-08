return Module("systems", {
  -- for keypressed/mousepressed order is not guaranteed
  -- love.keypressed systems --
  require("systems.input").system,

  -- love.mousepressed systems --
  require("systems.detect_clicks").system,

  -- love.update systems --
  require("systems.detect_hover").system,
  require("systems.acting").system,
  require("systems.animation").system,
  require("systems.timed_death").system,
  require("systems.drift").system,
  require("systems.railing").system,
  require("systems.sound").system,

  -- love.draw systems --
  require("systems.display").system,
})
