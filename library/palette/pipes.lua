local sprite = require("tech.sprite")
local sound = require("tech.sound")
local animated = require("tech.animated")
local library_fx = require("library.fx")
local interactive = require("tech.interactive")
local factoring = require("tech.factoring")
local shaders   = require("tech.shaders")


local pipes, pipes_mt, static = Module("library.palette.pipes")

local reflection_vectors = {
  horizontal = Vector.up,
  horizontal_braced = Vector.up,
  vertical = Vector.left,
  vertical_braced = Vector.left,
  left_back = Vector.up,
  forward_left = Vector.up,
  right_forward = Vector.left,
  back_right = Vector.up,
  left_down = Vector.up,
  forward_down = Vector.left,
  right_down = Vector.up,
  back_down = Vector.left,
  T_up = Vector.up,
  T_left = Vector.left,
  T_down = Vector.left,
  T_right = Vector.up,
  x = Vector.up,
  colored = Vector.left,
  leaking_left_down = Vector.up,
}

factoring.from_atlas(
  pipes, "assets/sprites/atlases/pipes.png",
  function(name)
    return {
      layer = "solids",
      view = "scene",
      transparent_flag = true,
      reflection_vector = reflection_vectors[name],
      shader = reflection_vectors[name] and shaders.reflective,  -- TODO remove and
    }
  end,
  {
    "horizontal", "horizontal_braced", "vertical", "vertical_braced",
    "left_back", "forward_left", "right_forward", "back_right",
    "left_down", "forward_down", "right_down", "back_down",
    "T_up", "T_left", "T_down", "T_right",
    "x", false, false, false,
    "colored", "leaking_left_down",
  }
)

local hissing_sound = sound("assets/sounds/steam_hissing_loop.wav", 1)
hissing_sound.source:setLooping(true)

factoring.extend(pipes, "leaking_left_down", {
  trigger_seconds = 5,
  overflow_counter = 0,
  sound_loop = hissing_sound,
  paused = false,

  ai = {run = function(self, entity, dt)
    if entity.paused then return end
    entity.overflow_counter = entity.overflow_counter + dt

    if entity.overflow_counter >= 60 then
      sound.play({entity.sound_loop}, entity.position)
      if Common.relative_period(1, dt, entity, "steam") then
        pipes.burst_with_steam(entity)
      end
      return
    end
    entity.sound_loop.source:stop()

    if Common.relative_period(entity.trigger_seconds, dt, entity, "steam") then
      entity.trigger_seconds = 8 + math.random() * 4
      pipes.burst_with_steam(entity)
    end
  end},
})

local steam_hissing_sound = sound("assets/sounds/steam_hissing.wav", 0.8)

pipes.burst_with_steam = Dump.ignore_upvalue_size .. function(pipe)
  State:add(Table.extend(
    library_fx.steam("right"),
    {position = pipe.position}
  ))
  sound.play({steam_hissing_sound}, pipe.position)
end

factoring.extend(pipes, "colored",
  interactive.detector(),
  {
    name = "Необычная труба",
  }
)

return pipes
