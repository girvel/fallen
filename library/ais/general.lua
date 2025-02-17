local railing = require("tech.railing")
local ai = require("tech.ai")
local api = ai.api
local actions = require("mech.creature.actions")
local hostility = require("mech.hostility")


local general_ai, module_mt, static = Module("library.ais.general")

general_ai.modes = Enum({
  run_away_to = {"destination"},
  skip_turn = {},
  normal = {},
})

module_mt.__call = function(_, works_outside_of_combat)
  return {
    mode = general_ai.modes.normal(),

    look_for_aggression = false,
    was_attacked_by = {},

    -- TODO optimize
    run = ai.async(function(self, entity, dt)
      if not State.combat and not works_outside_of_combat then return end
      if
        not api.in_combat(entity)
        and self.mode.enum_variant ~= general_ai.modes.run_away_to
      then return end

      Log.debug("--- %s ---" % Entity.name(entity))

      local was_attacked_by = self.was_attacked_by
      self.was_attacked_by = {}

      if self.look_for_aggression then
        self.look_for_aggression = false
        if Fun.iter(was_attacked_by):all(function(e) return e ~= State.player end) then
          hostility.make_friendly(entity.faction)
          return
        end
      end

      local mode_type = self.mode.enum_variant
      if mode_type == general_ai.modes.skip_turn then
        railing.api.message.temporal("Стой! Остановись, мужик!!! Не бей меня!", {source = entity})
        self.mode = general_ai.modes.normal()
        self.look_for_aggression = true
        return
      end

      if mode_type == general_ai.modes.run_away_to then
        api.travel(entity, self.mode:unpack())
        return
      end

      api.travel(entity, State.player.position)

      local direction = State.player.position - entity.position
      if direction:abs() == 1 then
        Log.debug("Attempt at attacking the player")
        entity:rotate(Vector.name_from_direction(direction))
        while entity:act(actions.hand_attack) do
          while not entity.animation.current.codename:starts_with("idle") do
            coroutine.yield()
          end
        end
      end
    end),

    observe = function(self, entity, dt)
      api.aggregate_aggression(self.was_attacked_by, entity)

      if self.look_for_aggression then
        entity.resources.reactions = 0
      end
    end,
  }
end

return general_ai
