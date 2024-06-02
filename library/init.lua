local level = require("level")
local random = require("utils.random")
local common = require("utils.common")


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

local get_modifier = function(ability_score)
  return math.floor((ability_score - 10) / 2)
end

-- TODO extract abstract shit
module.get_turn_resources = function(creature)
  return {
    movement = 6,
    actions = 1,
  }
end

-- TODO extract abstract shit
module.creature = function()
  return {
    turn_resources = {
      movement = 6,
      actions = 1,
    },
    abilities = {
      strength = 10,
      dexterity = 10,
    },
    direction = "right",

    get_armor = function(self)
      return 10 + get_modifier(self.abilities.dexterity)
    end,
  }
end

local move = function(direction_name)
  return function(entity, state)
    entity.direction = direction_name
    if (
      entity.turn_resources.movement > 0 and
      level.move(state.grids[entity.layer], entity, entity.position + Vector[direction_name])
    ) then
      entity.turn_resources.movement = entity.turn_resources.movement - 1

      if entity.animation then
        entity.animation.current = "move_" .. direction_name -- TODO something like animation:play
      end
    end
  end
end

local hand_attack = function(entity, state, target)
  if entity.turn_resources.actions <= 0 then return end
  if not target or not target.hp then return end
  entity.turn_resources.actions = entity.turn_resources.actions - 1

  local attack_roll = random.d(20) + get_modifier(entity.abilities.strength)
  Log.info(
    entity.name .. " attacks " .. target.name .. "; attack roll: " ..
    attack_roll .. ", armor: " .. target:get_armor()
  )

  if attack_roll < target:get_armor() then return end

  local damage = math.max(1, (entity.abilities.strength - 10) / 2)
  Log.info("damage: " .. damage)

  target.hp = target.hp - damage
  if target.hp <= 0 then
    state:remove(target)
    Log.info(target.name .. " is killed")
  end
end

local hotkeys = {
  w = move("up"),
  a = move("left"),
  s = move("down"),
  d = move("right"),

  space = function()
    return true
  end,

  f = function(entity, state)
    return hand_attack(entity, state, state.grids.solids[entity.position + Vector.right])
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
  return common.extend(module.creature(), {
    name = "player",
    sprite = {
    },
    animation = {
      pack = player_character_pack,
      current = "idle_right",
      frame = 1,
    },
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
end

local bat_pack = load_animation_pack("assets/sprites/bat")

module.bat = function()
  return common.extend(module.creature(), {
    name = "bat",
    hp = 2,
    sprite = {
    },
    animation = { -- TODO animation()
      pack = bat_pack,
      current = "idle",
      frame = 1,
    },
    turn_resources = {
      movement = 6,
      actions = 1,
    },
    ai = function(self, state)
      if random.chance(0.5) then
        return true
      end
      move(random.choice({"up", "down", "left", "right"}))(self, state)
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
