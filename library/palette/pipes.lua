local sprite = require("tech.sprite")
local sound = require("tech.sound")
local animated = require("tech.animated")
local library_fx = require("library.fx")
local interactive = require("tech.interactive")
local factoring = require("tech.factoring")


local pipes, pipes_mt, static = Module("library.palette.pipes")

factoring.from_atlas(pipes, "assets/sprites/atlases/pipes.png", {
  layer = "solids",
  view = "scene",
  transparent_flag = true,
}, {
  "horizontal", "horizontal_braced", "vertical", "vertical_braced",
  "left_back", "forward_left", "right_forward", "back_right",
  "left_down", "forward_down", "right_down", "back_down",
  "T_up", "T_left", "T_down", "T_right",
  "x", false, false, false,
  "colored", "leaking_left_down",
})

local hissing_sound = sound.multiple("assets/sounds/steam_hissing_loop.wav", 1)[1]
hissing_sound.source:setLooping(true)

factoring.extend(pipes, "leaking_left_down", {
  trigger_seconds = 5,
  overflow_counter = 0,
  sound_loop = hissing_sound,
  paused = false,

  ai = {run = function(self, dt)
    self.overflow_counter = self.overflow_counter + dt

    if self.overflow_counter >= 60 then
      State.audio:play(self, self.sound_loop)
      if Common.relative_period(1, dt, self, "steam") then
        pipes.burst_with_steam(self)
      end
      return
    end
    self.sound_loop.source:stop()

    if Common.relative_period(self.trigger_seconds, dt, self, "steam") then
      self.trigger_seconds = 8 + math.random() * 4
      pipes.burst_with_steam(self)
    end
  end},
})

local steam_hissing_sound = sound.multiple("assets/sounds/steam_hissing.wav", 0.8)[1]

pipes.burst_with_steam = Dump.ignore_upvalue_size .. function(pipe)
  State:add(Table.extend(
    library_fx.steam("right"),
    {position = pipe.position}
  ))
  State.audio:play(pipe, steam_hissing_sound:clone())
end

factoring.extend(pipes, "colored",
  interactive.detector(true),
  {
    name = "Необычная труба",
  }
)

return pipes
