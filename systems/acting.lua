local combat = require("tech.combat")
local fx = require("tech.fx")
local animated = require("tech.animated")
local item = require("tech.item")
local sound = require("tech.sound")
local hostility = require("mech.hostility")


local your_move_sound = sound.multiple("assets/sounds/your_move1", 0.5)[1]

local blood_factory = function()
  return Tablex.extend(
    item.mixin(),
    animated("assets/sprites/hurt", "atlas"),
    {
      direction = "right",
      name = "Кровь",
      codename = "blood",
      slot = "hurt",
    }
  )
end

local acting, _, static = Module("systems.acting")

acting.system = static(Tiny.processingSystem({
  codename = "acting",
  filter = Tiny.requireAll("ai"),
  base_callback = "update",

  preProcess = function()
    State.aggression_log = State._next_aggression_log
    State._next_aggression_log = {}
    if State.combat then
      local combatants = State.combat:iter_entities_only():totable()

      if Fun.iter(combatants):all(function(a)
        return Fun.iter(combatants):all(function(b) return not hostility.are_hostile(a, b) end)
      end) then
        Log.info(
          "Fight ends as only %s are left standing"
           % table.concat(Fun.iter(combatants)
            :map(Common.get_name)
            :totable(), ", ")
        )
        Fun.iter(combatants):each(function(e)
          Tablex.extend(e.resources, -Query(e):get_resources("short") or {})
        end)
        State.combat = nil
      end
    end
  end,

  process = function(self, entity, event)
    if entity.hp then
      if entity.hp <= entity:get_max_hp() / 2 then
        if not entity.inventory.hurt then
          local blood = State:add(blood_factory())
          State:add_dependency(entity, blood)
          blood.direction = entity.direction
          blood:animate(entity.animation.current)
          blood.animation.paused = entity.animation.paused
          -- TODO abstract this away as picking up an item?
          entity.inventory.hurt = blood
        end
      else
        if entity.inventory.hurt then
          State:remove(entity.inventory.hurt)
          entity.inventory.hurt = nil
        end
      end
    end

    Query(entity.ai).observe(entity, event)
    if not entity.ai.run then return end

    -- TODO! REF
    if not State.combat then
      entity.ai.run(entity, event)
      if -Query(entity.animation).current:startsWith("idle") then
        Tablex.extend(entity.resources, -Query(entity):get_resources("move"))
      end
      return
    end

    local is_world_turn = State.combat:get_current() == combat.WORLD_TURN

    if is_world_turn then
      if Tablex.contains(State.combat.list, entity) then return end
    elseif State.combat:get_current() ~= entity then return end

    if is_world_turn then
      event = {6}  -- 1 round is 6 seconds
    end

    local was_timeout_reached = (
      not entity.player_flag
      and Common.period(20, self, State.combat:get_current())
    )

    if was_timeout_reached then
      Log.warn("%s's turn timed out" % Common.get_name(State.combat:get_current()))
    end

    if
      entity.ai.run(entity, event) == combat.TURN_END_SIGNAL and not is_world_turn
      or was_timeout_reached
    then
      self:_pass_turn()
    end
  end,

  postProcess = function(self)
    if -Query(State.combat):get_current() == combat.WORLD_TURN then
      self:_pass_turn()
    end
  end,

  _pass_turn = function(self)
    local current = State.combat:get_current()
    Common.reset_period(self, current)
    Tablex.extend(current.resources, -Query(current):get_resources("move") or {})
    State.combat:move_to_next()
    current = State.combat:get_current()
    Log.info("%s's turn" % Common.get_name(current))

    if current == State.player then
      State.audio:play_static(your_move_sound)
      State:add(fx("assets/sprites/fx/turn_starts", "fx_behind", current.position))
    end
  end,
}))

return acting
