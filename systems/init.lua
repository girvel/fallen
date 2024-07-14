return {
  -- TODO group by callback & period

  -- love.draw systems --
  require("systems.display"),

  require("systems.input"),
  require("systems.acting"),
  require("systems.animation"),
  require("systems.timed_death"),
  require("systems.drift"),
  require("systems.railing"),
  require("systems.on_click_calls"),
}
