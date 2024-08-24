local sprite = require("tech.sprite")
local sound = require("tech.sound")
local animated = require("tech.animated")
local library_fx = require("library.fx")
local interactive = require("tech.interactive")
local random = require("utils.random")
local factoring = require("tech.factoring")


local pipes, pipes_mt, static = Module("library.pipes")
local atlas = "assets/sprites/atlases/pipes.png"

factoring.from_atlas(pipes, atlas, {
  layer = "solids",
  view = State.gui.views.scene,
  transparent_flag = true,
}, {
  "horizontal", "vertical", "horizontal_braced", "vertical_braced",
  "left_back", "forward_left", "right_forward", "back_right",
  "left_down", "forward_down", "right_down", "back_down",
  "T_up", "T_left", "T_down", "T_right",
  "x", "colored",
})

local valve_rotating_sounds = sound.multiple("assets/sounds/valve_rotate", 0.1)
local pipe_valve_pack = animated.load_pack("assets/sprites/animations/pipe_valve")

pipes.valve = function(leaking_pipe_position)
  return Tablex.extend(
    animated(pipe_valve_pack),
    interactive(Dump.ignore_upvalue_size .. function(self, other)
      local target = State.grids.solids[leaking_pipe_position]
      State.audio:play(self, random.choice(valve_rotating_sounds), "medium")
      self:animate("rotate"):next(function()
        target.overflow_counter = 0
        pipes.burst_with_steam(target)
      end)
    end, true),
    {
      layer = "solids",
      view = State.gui.views.scene,
      name = "Вентиль",
      codename = "valve",
      transparent_flag = true,
    }
  )
end

pipes.leaking_left_down = function()
  local hissing_sound = sound.multiple("assets/sounds/steam_hissing_loop.wav", 1)[1]
  hissing_sound.source:setLooping(true)

  return {
    sprite = sprite.from_atlas(atlas, 9),
    layer = "solids",
    view = State.gui.views.scene,
    transparent_flag = true,

    codename = "leaking_left_down",
    trigger_seconds = 5,
    overflow_counter = 0,
    sound_loop = hissing_sound,
    paused = false,

    ai = {run = function(self, event)
      local dt = unpack(event)
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
  }
end

local steam_hissing_sound = sound.multiple("assets/sounds/steam_hissing.wav", 0.8)[1]

pipes.burst_with_steam = Dump.ignore_upvalue_size .. function(pipe)
  State:add(Tablex.extend(
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
