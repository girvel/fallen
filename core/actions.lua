local creature = require("core.creature")
local level = require("level")
local random = require("utils.random")


local module = {}

module.move = function(direction_name)
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

module.hand_attack = function(entity, state, target)
  if entity.turn_resources.actions <= 0 then return end
  if not target or not target.hp then return end
  entity.turn_resources.actions = entity.turn_resources.actions - 1

  local attack_roll = random.d(20) + creature.get_modifier(entity.abilities.strength)
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

return module
