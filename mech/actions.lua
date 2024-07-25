local level = require("tech.level")
local attacking = require("mech.attacking")
local constants = require("mech.constants")
local random = require("utils.random")
local mech = require("mech")
local static_sprite = require("tech.static_sprite")
local interactive = require("tech.interactive")


local actions = {}

-- Post-Plot MVP refactor plans:
-- Action: {cost, _isAvailable(), execute()}
-- Level-dependency is stored in class
-- Hotkey is stored in player AI
-- Picture, description etc. is stored in GUI

local get_melee_attack_roll = function(entity)
  local roll = D(20) + entity.proficiency_bonus

  local weapon = entity.inventory.main_hand
  if not weapon then
    return roll + mech.get_modifier(entity.abilities.strength)
  end

  roll = roll + weapon.bonus
  if weapon.tags.finesse then
    roll = roll + mech.get_modifier(math.max(
      entity.abilities.strength,
      entity.abilities.dexterity
    ))
  else
    roll = roll + mech.get_modifier(entity.abilities.strength)
  end

  return roll
end

local get_melee_damage_roll = function(entity)
  if not entity.inventory.main_hand then
    return D.roll({}, mech.get_modifier(entity.abilities.strength))
  end

  local ability_modifier = mech.get_modifier(
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

local direction_translations = {
  up = "вверх",
  left = "влево",
  down = "вниз",
  right = "вправо",
}

local directional_hotkeys = {
  up = "w",
  left = "a",
  down = "s",
  right = "d",
}

actions.move = Fun.iter(Vector.direction_names):map(function(direction_name)
  return direction_name, {
    name = "двигаться " .. direction_translations[direction_name],
    hotkey = directional_hotkeys[direction_name],
    run = function(_, entity)
      entity:rotate(direction_name)

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
            and mech.are_hostile(entity, e)
            and e.turn_resources
            and e.turn_resources.reactions > 0
          end)
        :each(function(e)
          e.turn_resources.reactions = e.turn_resources.reactions - 1
          e.direction = Vector.name_from_direction(old_position - e.position)
          e:animate("attack")
          e:when_animation_ends(function()
            attacking.attack(
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
    end,
  }
end):tomap()

actions.hand_attack = Tablex.extend(
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

      State:register_agression(entity, target)

      entity:animate("attack")
      entity:when_animation_ends(function()
        if not attacking.attack(
          entity, target,
          get_melee_attack_roll(entity),
          get_melee_damage_roll(entity)
        ) then return end

        if target and target.sounds and target.sounds.hit then
          random.choice(target.sounds.hit):play()
        end

        if target.hardness and not -Query(entity).inventory.main_hand then
          attacking.attack_save(entity, "constitution", target.hardness, D.roll({}, 1))
        end
      end)
      return true
    end
  }
)

actions.dash = {
  run = function(_, entity)
    if entity.turn_resources.actions <= 0 then
      return
    end

    entity.turn_resources.actions = entity.turn_resources.actions - 1
    entity.turn_resources.movement = entity.turn_resources.movement + entity:get_turn_resources().movement
  end,
}

actions.interact = {
  run = function(entity)
    if entity.turn_resources.bonus_actions <= 0 then return end
    local entity_to_interact = interactive.get_for(entity)
    if not entity_to_interact then return end
    if entity_to_interact.position ~= entity.position and not entity_to_interact.hp then
      entity:animate("attack")
    end
    entity.turn_resources.bonus_actions = entity.turn_resources.bonus_actions - 1
    entity_to_interact:interact(entity)
  end
}

actions.list = {
  actions.move.up,
  actions.move.left,
  actions.move.down,
  actions.move.right,
  actions.hand_attack,
  actions.interact,
  actions.dash,
}

return actions
