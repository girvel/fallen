local actions = require("core.actions")
local random = require("utils.random")
local common = require("utils.common")
local creature = require("core.creature")


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
    return actions.hand_attack(entity, state, state.grids.solids[entity.position + Vector[entity.direction]])
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
  local result = common.extend(creature(player_character_pack), {
    name = "player",
    direction = "right",
    ai = function(self, state)
      local action = hotkeys[self.last_pressed_key]
      self.last_pressed_key = nil
      if action ~= nil then return action(self, state) end
    end,
    abilities = {
      strength = 12,
      dexterity = 10,
    },
  })

  result.inventory.main_hand = {
    name = "dagger",
    die_sides = 4,
    bonus = 1,
  }

  return result
end

local bat_pack = load_animation_pack("assets/sprites/bat")

module.bat = function()
  return common.extend(creature(bat_pack), {
    name = "bat",
    hp = 2,
    ai = function(self, state)
      if random.chance(0.5) then
        return true
      end
      actions.move(random.choice({"up", "down", "left", "right"}))(self, state)
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

return module
