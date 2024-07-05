return {
  -- TODO group by callback & period

  -- love.draw systems --
  require("systems.display_scene"),
  require("systems.display_off_grid"),
  require("systems.display_gui"),
  require("systems.display_hovered_links"),

  require("systems.input"),
  require("systems.ai"),
  require("systems.animation"),
  require("systems.timed_death"),
  require("systems.drift"),
  require("systems.railing"),
  require("systems.on_click_calls"),
}
