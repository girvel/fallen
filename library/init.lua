local actions = require("core.actions")
local random = require("utils.random")
local common = require("utils.common")
local creature = require("core.creature")
local mech = require("core.mech")
local classes = require("core.classes")
local animated = require("animated")


local module = {}

module.wall = function()
  return {
    sprite = {
      image = love.graphics.newImage("assets/sprites/wall.png"),
    },
  }
end

module.planks = function()
  return {
    sprite = {
      image = love.graphics.newImage("assets/sprites/planks.png")
    }
  }
end

module.grass = function()
  return {
    sprite = {
      image = love.graphics.newImage("assets/sprites/grass.png")
    }
  }
end

local hotkeys = {
  w = actions.move("up"),
  a = actions.move("left"),
  s = actions.move("down"),
  d = actions.move("right"),

  space = function()
    return true
  end,

  f = function(entity, state)
    actions.hand_attack(entity, state, state.grids.solids[entity.position + Vector[entity.direction]])
  end,

  g = function(entity, state)
    actions.sneak_attack(entity, state, state.grids.solids[entity.position + Vector[entity.direction]])
  end,

  q = function(entity, state)
    if entity.turn_resources.bonus_actions <= 0 then return end
    entity.turn_resources.bonus_actions = entity.turn_resources.bonus_actions - 1

    Fun.iter(pairs(state.grids.solids._inner_array))
      :filter(function(e)
        return e and e.hp and e ~= entity and (e.position - entity.position):abs() <= 3
      end)
      :each(function(e)
        mech.damage(e, state, 1, false)
      end)
  end,

  z = function(entity)
    actions.aim(entity)
  end,

  e = function(entity, state)
    if entity.turn_resources.bonus_actions <= 0 then return end

    local entity_to_interact = Fun.iter({
      state.grids.tiles[entity.position],
      state.grids.solids[entity.position + Vector[entity.direction]],
    })
      :filter(function(x) return x.interact end)
      :nth(1)

    if not entity_to_interact then return end
    entity.turn_resources.bonus_actions = entity.turn_resources.bonus_actions - 1

    entity_to_interact:interact(entity, state)
  end,

  escape = function(entity)
    if entity.reads then
      entity.reads = nil
      return
    end
  end,
}

local load_animation_pack = function(folder_path)
  local result = {}
  for _, file_name in ipairs(love.filesystem.getDirectoryItems(folder_path)) do
    local i = file_name:find("%.png$")
    local frame_number = tonumber(file_name:sub(i - 2, i - 1))
    local animation_name
    if frame_number then
      animation_name = file_name:sub(0, i - 4)
    else
      frame_number = 1
      animation_name = file_name:sub(0, i - 1)
    end

    if not result[animation_name] then result[animation_name] = {} end
    result[animation_name][frame_number] = love.graphics.newImage(folder_path .. "/" .. file_name)
  end
  return result
end

local player_character_pack = load_animation_pack("assets/sprites/player_character")

module.player = function()
  local result = creature(player_character_pack, {
    name = "player",
    class = classes.rogue,
    level = 1,
    direction = "right",
    ai = function(self, state)
      local action = hotkeys[self.last_pressed_key]
      self.last_pressed_key = nil
      if action ~= nil then return action(self, state) end
    end,
    abilities = {
      strength = 8,
      dexterity = 18,
      constitution = 14,
      intelligence = 12,
      wisdom = 12,
      charisma = 11,
    },
    reads = nil,
  })

  result.inventory.main_hand = {
    name = "dagger",
    damage_roll = D(4) + 1,
  }

  return result
end

local bat_pack = load_animation_pack("assets/sprites/bat")

module.bat = function()
  return creature(bat_pack, {
    name = "bat",
    max_hp = 200,
    hungry = true,
    ai = function(self, state, event)
      local dt = unpack(event)
      if not common.period(self, .25, dt) then return end
      if not self._ai_coroutine then
        self._ai_coroutine = coroutine.create(self.async_ai)
      end

      local success, message = coroutine.resume(self._ai_coroutine, self, state)
      if not success then
        Log.error("Coroutine error: " .. message)
      end

      if coroutine.status(self._ai_coroutine) == "dead" then
        self._ai_coroutine = nil
        return true
      end
    end,
    async_ai = function(self, state)
      for _ in Fun.range(self.turn_resources.movement) do
        if self.hungry then
          local target = Fun.iter(Vector.directions)
            :map(function(v) return state.grids.solids:safe_get(self.position + v) end)
            :filter(function(e) return e and e.hp end)
            :nth(1)

          if target and actions.hand_attack(self, state, target) then
            self.hungry = false
          end
        end

        actions.move(random.choice(Vector.direction_names))(self, state)
        coroutine.yield()
      end
    end,
  })
end

module.smooth_wall = function()
  return {
    sprite = {
      image = love.graphics.newImage("assets/sprites/smooth_wall.png")
    }
  }
end

module.crooked_wall = function()
  return {
    sprite = {
      image = love.graphics.newImage("assets/sprites/crooked_wall.png")
    }
  }
end

local highlight_pack = load_animation_pack("assets/sprites/highlight")

module.highlight = function()
  return common.extend(animated(highlight_pack), {layer = "sfx"})
end

module.scripture_straight = function()
  return {
    was_interacted_with = false,
    interact = function(self, other, state)
      other.reads = "Hello, VSauce! Michael here.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

      self.was_interacted_with = true
      if self._highlight then
        state:remove(self._highlight)
        self._highlight = nil
      end
    end,
    on_load = function(self, state)
      self._highlight = state:add(common.extend(module.highlight(), {position = self.position}))
    end,
    sprite = {
      image = love.graphics.newImage("assets/sprites/scripture_straight.png")
    }
  }
end

return module
