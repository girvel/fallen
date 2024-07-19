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
local pathfinder = require("lib.jumper.pathfinder")
local jgrid = require("lib.jumper.grid")


local module = {}

local engineer_mixin = function()
  return Tablex.extend(
    interactive(function(self, other)
      self.talking_to = other
    end),
    {name = "инженер"}
  )
end

-- [{7, 9}] = {"down", {main_hand = weapons.gas_key()}},
-- [{5, 8}] = {"down"},
-- [{5, 3}] = {"up", {gloves = weapons.yellow_glove()}},
-- [{8, 3}] = {"up"},

module[1] = function()
  return humanoid(Tablex.extend({
    race = races.half_elf,
    max_hp = 1,
    direction = "down",
    inventory = {main_hand = weapons.gas_key()},

    ai = function() end,

    talking_to = nil,
  }, engineer_mixin()))
end

module[2] = function()
  return humanoid(Tablex.extend({
    race = races.halfling,
    max_hp = 1,
    direction = "down",
    inventory = {},

    ai = function() end,

    talking_to = nil,
  }, engineer_mixin()))
end

module[3] = function()
  return humanoid(Tablex.extend({
    race = races.half_orc,
    max_hp = 22,
    direction = "up",
    inventory = {gloves = weapons.yellow_glove()},

    abilities = core.abilities(16, 12, 12, 8, 8, 8),
    save_proficiencies = {dexterity = true},

    -- TODO optimize
    ai = ai.async(function(self)
      if not State.move_order then return end

      local direction = State.player.position - self.position
      if direction:abs() > 1 then
        local self_x, self_y = unpack(self.position)
        local other_x, other_y = unpack(State.player.position)

        State.collision_map[self_y][self_x] = 0
        State.collision_map[other_y][other_x] = 0

        local finder = pathfinder(jgrid(State.collision_map), "ASTAR", 0)
        pathfinder:setMode("ORTHOGONAL")
        local path = finder:getPath(self_x, self_y, unpack(State.player.position))

        local result = {}
        for node, count in path:nodes() do
          table.insert(result, Vector({node:getX(), node:getY()}))
        end

        Log.trace(result)

        local i = 1
        local is_moving = true
        while is_moving do
          if self.turn_resources.movement <= 0 then
            if self.turn_resources.actions > 0 then
              actions.dash(self)
            else
              is_moving = false
              break
            end
          end

          if i > #result then
            return
          end

          local destination = result[i]
          direction = (destination - self.position)
          if direction:abs() > 0 then
            actions.move[Log.trace(Vector.name_from_direction(direction:normalized()))](self)
            coroutine.yield()
          else
            i = i + 1
          end
        end
      end

      self.direction = direction
      actions.hand_attack(self)
    end),

    talking_to = nil,
  }, engineer_mixin()))
end

module[4] = function()
  return humanoid(Tablex.extend({
    race = races.dwarf,
    max_hp = 1,
    direction = "up",
    inventory = {},

    ai = function() end,

    talking_to = nil,
  }, engineer_mixin()))
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
