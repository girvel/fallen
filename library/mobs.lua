local actions = require("core.actions")
local random = require("utils.random")
local creature = require("core.creature")
local humanoid = require("core.humanoid")
local animated = require("tech.animated")
local interactive = require("tech.interactive")
local turn_order = require("tech.turn_order")
local weapons = require("library.weapons")
local core = require("core")
local races = require("core.races")
local ai = require("tech.ai")
local constants = require("core.constants")


local module = {}

local engineer_mixin = function()
  return Tablex.extend(
    interactive(function(self, other)
      self.talking_to = other
    end),
    {
      talking_to = nil,

      -- TODO optimize
      ai = ai.async(function(self)
        Log.debug("--- %s ---" % Common.get_name(self))
        if not State.move_order then return end

        if self.run_away_to then
          Log.trace("Attempt at building path to run away")
          local path = State.grids.solids:find_path(self.position, self.run_away_to)
          Log.trace("%s runs away; path: %s" % {Common.get_name(self), Inspect(path)})

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
          local path = Log.trace(State.grids.solids:find_path(self.position, State.player.position))
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
    }
  )
end

local dreamer_engineer_mixin = function()
  return Tablex.extend(
    engineer_mixin(),
    {
      max_hp = 22,
      abilities = core.abilities(14, 14, 12, 8, 8, 8),
      faction = "dreamers",
    }
  )
end

-- [{7, 9}] = {"down", {main_hand = weapons.gas_key()}},
-- [{5, 8}] = {"down"},
-- [{5, 3}] = {"up", {gloves = weapons.yellow_glove()}},
-- [{8, 3}] = {"up"},

module[1] = function()
  return humanoid(Tablex.extend({
    name = "инженер #1",
    race = races.half_elf,
    direction = "down",
    inventory = {main_hand = weapons.gas_key()},
  }, dreamer_engineer_mixin()))
end

module[2] = function()
  return humanoid(Tablex.extend({
    name = "инженер #2",
    race = races.halfling,
    direction = "down",
    inventory = {},
  }, dreamer_engineer_mixin()))
end

module[3] = function()
  return humanoid(Tablex.extend({
    name = "инженер #3",
    race = races.half_orc,
    hp = 34,
    max_hp = 35,
    direction = "up",
    inventory = {gloves = weapons.yellow_glove()},
    faction = "dreamers",

    abilities = core.abilities(18, 6, 12, 8, 8, 8),
    save_proficiencies = {dexterity = true},

    talking_to = nil,

    get_turn_resources = function()
      return {
        movement = constants.DEFAULT_MOVEMENT_SPEED,
        actions = 2,
        bonus_actions = 1,
        reactions = 1,
      }
    end,
  }, engineer_mixin()))
end

module[4] = function()
  return humanoid(Tablex.extend({
    name = "инженер #4",
    race = races.dwarf,
    direction = "up",
    inventory = {},
  }, dreamer_engineer_mixin()))
end

local bat_pack = animated.load_pack("assets/sprites/bat")

module.bat = function()
  return creature(bat_pack, {
    name = "летучая мышь",
    max_hp = 3,
    faction = "monster",
    ai = function(self, event)
      if not State.move_order then return end

      local dt = unpack(event)
      if not Common.period(self, .25, dt) then return end
      if not self._ai_coroutine then
        self._ai_coroutine = coroutine.create(self.async_ai)
      end

      local success, message = coroutine.resume(self._ai_coroutine, self)
      if not success then
        Log.error("Coroutine error: " .. message)
      end

      if coroutine.status(self._ai_coroutine) == "dead" then
        self._ai_coroutine = nil
        return true
      end
    end,
    async_ai = function(self)
      for _ in Fun.range(self.turn_resources.movement) do
        if self.hungry then
          local target = Fun.iter(Vector.directions)
            :map(function(v) return State.grids.solids:safe_get(self.position + v) end)
            :filter(function(e) return e and e.hp end)
            :nth(1)

          if target then actions.hand_attack(self, target) end
        end

        actions.move[random.choice(Vector.direction_names)](self)
        coroutine.yield()
      end
    end,
  })
end

local exploding_dude_pack = animated.load_pack("assets/sprites/exploding_dude")

module.exploding_dude = function()
  return Tablex.extend(
    animated(exploding_dude_pack),
    interactive(function(self, other)
      self.interact = nil
      self:animate("explode")
      self:when_animation_ends(function()
        State:remove(self)

        local bats = {}
        for _ = 1, 3 do
          local v
          for _ = 1, 1000 do
            v = self.position + Vector({
              math.random(11) - 6,
              math.random(11) - 6,
            })
            if State.grids.solids:safe_get(v) == nil then break end
          end

          local bat = State:add(Tablex.extend(module.bat(), {position = v}))
          bat:animate("appear")
          table.insert(bats, bat)
        end

        bats[#bats]:when_animation_ends(function()
          State.move_order = turn_order(Tablex.concat(bats, {other}))
        end)
      end)
    end),
    {
      name = "таинственный силуэт",
    }
  )
end

return module
