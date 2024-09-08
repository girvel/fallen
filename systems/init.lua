return Module("systems", {
  -- event systems --
  -- (in random order)
  require("systems.collect_scancodes").system,  -- keypressed
  require("systems.detect_clicks").system,  -- mousepressed

  -- love.update systems --
  require("systems.process_scancodes").system,
  require("systems.change_cursor").system,
  require("systems.detect_hover").system,
  require("systems.trigger_tooltip").system,
  require("systems.acting").system,
  require("systems.animation").system,
  require("systems.timed_death").system,
  require("systems.drift").system,
  require("systems.railing").system,
  require("systems.music").system,
  require("systems.writing_text").system,

  -- love.draw systems --
  require("systems.display").system,
})
