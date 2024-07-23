local ai = require("tech.ai")
local actions = require("core.actions")


local engineer_ai_mt = {}
local engineer_ai = setmetatable({}, engineer_ai_mt)

engineer_ai.modes = Enum("library.engineer_ai.modes", {
  run_away_to = {"destination"},
  skip_turn = {},
  normal = {},
})

engineer_ai_mt.__call = function(_)
  return {
    mode = engineer_ai.modes.normal(),

    look_for_agression = nil,
    was_attacked_by = {},

    -- TODO optimize
    run = ai.async(function(self, dt)
      if not -Query(State.move_order):contains(self) then return end
      Log.debug("--- %s ---" % Common.get_name(self))

      local was_attacked_by = self.was_attacked_by
      self.was_attacked_by = {}

      local mode_type = self.ai.mode.enum_variant
      if mode_type == engineer_ai.modes.skip_turn then
        Log.debug("Skips turn")
        self.ai.mode = engineer_ai.modes.normal()
        return
      end

      if mode_type == engineer_ai.modes.run_away_to then
        local destination = self.ai.mode:unpack()
        local path = State.grids.solids:find_path(self.position, destination)

        for _, position in ipairs(path) do
          if self.turn_resources.movement <= 0 then
            if self.turn_resources.actions > 0 then
              actions.dash(self)
            else
              break
            end
          end

          local direction = (position - self.position)
          if not actions.move[Vector.name_from_direction(direction:normalized())](self) then return end
          coroutine.yield()
        end
        return
      end

      if (State.player.position - self.position):abs() > 1 then
        Log.debug("Attempt at building path towards player")
        local path = State.grids.solids:find_path(self.position, State.player.position)
        Log.debug("Path is built")
        table.remove(path)

        for _, position in ipairs(path) do
          if self.turn_resources.movement <= 0 then
            if self.turn_resources.actions > 0 then
              actions.dash(self)
            else
              break
            end
          end

          local direction = (position - self.position)
          if not actions.move[Vector.name_from_direction(direction:normalized())](self) then return end
          coroutine.yield()
        end
      end

      local direction = State.player.position - self.position
      if direction:abs() == 1 then
        Log.debug("Attempt at attacking the player")
        self:rotate(Vector.name_from_direction(direction))
        while actions.hand_attack(self) do
          while not self.animation.current:startsWith("idle") do
            coroutine.yield()
          end
        end
      end
    end),

    observe = function(self, event)
      Tablex.concat(self.was_attacked_by, Fun.iter(State.agression_log)
        :filter(function(pair) return pair[2] == self end)
        :map(function(pair) return pair[1] end)
        :totable())
    end,
  }
end

return engineer_ai
