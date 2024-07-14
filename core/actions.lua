local level = require("tech.level")
local mech = require("core.mech")
local constants = require("core.constants")
local random = require("utils.random")
local core = require("core")
local static_sprite = require("tech.static_sprite")
local interactive = require("tech.interactive")


local module = {}

-- Post-Plot MVP refactor plans:
-- Action: {cost, _isAvailable(), execute()}
-- Level-dependency is stored in class
-- Hotkey is stored in player AI
-- Picture, description etc. is stored in GUI

local get_melee_attack_roll = function(entity)
  local roll = D(20) + entity.proficiency_bonus

  local weapon = entity.inventory.main_hand
  if not weapon then
    return roll + core.get_modifier(entity.abilities.strength)
  end

  roll = roll + weapon.bonus
  if weapon.tags.finesse then
    roll = roll + core.get_modifier(math.max(
      entity.abilities.strength,
      entity.abilities.dexterity
    ))
  else
    roll = roll + core.get_modifier(entity.abilities.strength)
  end

  return roll
end

local get_melee_damage_roll = function(entity)
  if not entity.inventory.main_hand then
    return D.roll({}, core.get_modifier(entity.abilities.strength) + 1)
  end

  local ability_modifier = core.get_modifier(
    entity.inventory.main_hand.tags.finesse
    and math.max(
      entity.abilities.strength,
      entity.abilities.dexterity
    )
    or entity.abilities.strength
  )

  return entity.inventory.main_hand.damage_roll
    + ability_modifier
    + entity.inventory.main_hand.bonus
end

module.move = Fun.iter(Vector.direction_names):map(function(direction_name)
  return direction_name, function(entity)
    entity.direction = direction_name
    Fun.iter(entity.inventory or {})
      :each(function(_, e) e.direction = direction_name end)

    if entity.inventory and entity.inventory.main_hand then
      entity.inventory.main_hand.direction = entity.direction
      entity.inventory.main_hand:animate()
    end

    local old_position = entity.position
    if entity.turn_resources.movement <= 0
      or not level.move(State.grids[entity.layer], entity, entity.position + Vector[direction_name])
    then
      return false
    end

    entity.turn_resources.movement = entity.turn_resources.movement - 1

    Fun.iter(Vector.directions)
      :map(function(d) return State.grids.solids:safe_get(old_position + d) end)
      :filter(function(e)
        return e
          and e ~= entity
          and e.abilities
          and core.are_hostile(entity, e)
          and e.turn_resources
          and e.turn_resources.reactions > 0
        end)
      :each(function(e)
        e.turn_resources.reactions = e.turn_resources.reactions - 1
        e.direction = Vector.name_from_direction(old_position - e.position)
        e:animate("attack")
        e:when_animation_ends(function()
          mech.attack(
            e, entity,
            get_melee_attack_roll(e),
            get_melee_damage_roll(e)
          )
        end)
      end)

    if entity.animate then
      entity:animate("move")
    end

    local tile = State.grids.tiles[entity.position]
    if tile and tile.sounds and tile.sounds.move then
      random.choice(tile.sounds.move):play()
    end

    return true
  end
end):tomap()

module.hand_attack = setmetatable(
  Tablex.extend(
    static_sprite("assets/sprites/icons/melee_attack.png"),
    {
      scale = Vector({2, 2}),
      on_click = function(self, entity) return self:run(entity) end,
      size = Vector.one * 0.67,
      run = function(self, entity)
        local target = State.grids.solids:safe_get(entity.position + Vector[entity.direction])

        if entity.turn_resources.actions <= 0
          or not target
          or not target.hp
        then
          return false
        end

        entity.turn_resources.actions = entity.turn_resources.actions - 1

        entity:animate("attack")
        entity:when_animation_ends(function()
          if not mech.attack(
            entity, target,
            get_melee_attack_roll(entity),
            get_melee_damage_roll(entity)
          ) then return end

          if target and target.sounds and target.sounds.hit then
            random.choice(target.sounds.hit):play()
          end
        end)
      end
    }
  ),
  {
    __call = function(self, entity)
      self:run(entity)
    end
  }
)

module.sneak_attack = function(entity, target)
  if entity.turn_resources.actions <= 0
    or not target
    or not target.hp
    or not entity.inventory.main_hand
    or not entity.inventory.main_hand.is_finesse
    or not entity.turn_resources.has_advantage
  then
    return false
  end

  entity.turn_resources.actions = entity.turn_resources.actions - 1

  entity:animate("attack")
  entity:when_animation_ends(function()
    mech.attack(
      entity, target,
      get_melee_attack_roll(entity),
      get_melee_damage_roll(entity)
        + D(6) * math.ceil(entity.level / 2)
    )
  end)
end

module.aim = function(entity)
  if entity.turn_resources.bonus_actions <= 0
    or entity.turn_resources.movement < constants.DEFAULT_MOVEMENT_SPEED
  then
    return
  end

  entity.turn_resources.bonus_actions = entity.turn_resources.bonus_actions - 1
  entity.turn_resources.movement = entity.turn_resources.movement - constants.DEFAULT_MOVEMENT_SPEED

  entity.turn_resources.has_advantage = true
end

module.dash = function(entity)
  if entity.turn_resources.actions <= 0 then
    return
  end

  entity.turn_resources.actions = entity.turn_resources.actions - 1
  entity.turn_resources.movement = entity.turn_resources.movement + entity:get_turn_resources().movement
end

module.second_wind = setmetatable(
  Tablex.extend(
    static_sprite("assets/sprites/icons/second_wind.png"),
    {
      size = Vector.one * 0.67,
      on_click = function(self, entity) return self:run(entity) end,
      run = function(self, entity)
        if entity.turn_resources.bonus_actions <= 0
          or entity.turn_resources.second_wind <= 0
        then
          return
        end

        entity.turn_resources.bonus_actions = entity.turn_resources.bonus_actions - 1
        entity.turn_resources.second_wind = entity.turn_resources.second_wind - 1

        entity.hp = math.min(entity:get_max_hp(), entity.hp + (D(10) + entity.level):roll())
      end,
    }
  ),
  {
    __call = function(self, entity)
      self:run(entity)
    end
  }
)

module.action_surge = function(entity)
  if entity.turn_resources.action_surge <= 0 then
    return
  end
  entity.turn_resources.action_surge = entity.turn_resources.action_surge - 1
  entity.turn_resources.actions = entity.turn_resources.actions + 1
end

module.interact = function(entity)
  if entity.turn_resources.bonus_actions <= 0 then return end
  local entity_to_interact = interactive.get_for(entity)
  if not entity_to_interact then return end
  if entity_to_interact.position ~= entity.position and not entity_to_interact.hp then
    entity:animate("attack")
  end
  entity.turn_resources.bonus_actions = entity.turn_resources.bonus_actions - 1
  entity_to_interact:interact(entity)
end

return module
