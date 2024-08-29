local railing = require("tech.railing")
local ai = require("tech.ai")
local api = ai.api
local actions = require("mech.creature.actions")
local hostility = require("mech.hostility")


local general_ai, general_ai_mt, static = Module("library.general_ai")

general_ai.modes = Enum({
  run_away_to = {"destination"},
  skip_turn = {},
  normal = {},
})

general_ai_mt.__call = function(_, works_outside_of_combat)
  return {
    mode = general_ai.modes.normal(),

    look_for_aggression = false,
    was_attacked_by = {},

    -- TODO optimize
    run = ai.async(function(self, dt)
      if
        not State.combat
        and self.ai.mode.enum_variant ~= general_ai.modes.run_away_to
      then return end

      Log.debug("--- %s ---" % Common.get_name(self))

      local was_attacked_by = self.ai.was_attacked_by
      self.ai.was_attacked_by = {}

      if self.ai.look_for_aggression then
        self.ai.look_for_aggression = false
        if Fun.iter(was_attacked_by):all(function(e) return e ~= State.player end) then
          hostility.make_friendly(self.faction)
          return
        end
      end

      local mode_type = self.ai.mode.enum_variant
      if mode_type == general_ai.modes.skip_turn then
        railing.api.message.temporal("Стой! Остановись, мужик!!! Не бей меня!")
        self.ai.mode = general_ai.modes.normal()
        self.ai.look_for_aggression = true
        return
      end

      if mode_type == general_ai.modes.run_away_to then
        api.travel(self, self.ai.mode:unpack())
        return
      end

      api.travel(self, State.player.position)

      local direction = State.player.position - self.position
      if direction:abs() == 1 then
        Log.debug("Attempt at attacking the player")
        self:rotate(Vector.name_from_direction(direction))
        while self:act(actions.hand_attack) do
          while not self.animation.current:startsWith("idle") do
            coroutine.yield()
          end
        end
      end
    end, works_outside_of_combat),

    observe = function(self, dt)
      api.aggregate_aggression(self.ai.was_attacked_by, self)

      if self.ai.look_for_aggression then
        self.resources.reactions = 0
      end
    end,
  }
end

return general_ai
