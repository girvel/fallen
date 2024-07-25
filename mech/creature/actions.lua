local level = require("tech.level")
local attacking = require("mech.attacking")
local random = require("utils.random")
local mech = require("mech")
local static_sprite = require("tech.static_sprite")
local interactive = require("tech.interactive")
local combat = require("tech.combat")


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

local base_attack = function(entity, target)
  State:register_agression(entity, target)

  entity:rotate(Vector.name_from_direction((target.position - entity.position):normalized()))
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
end

actions.hand_attack = Tablex.extend(
  static_sprite("assets/sprites/icons/melee_attack.png"),
  {
    codename = "hand_attack",
    scale = Vector({2, 2}),
    on_click = function(self, entity) return entity:act(self) end,
    size = Vector.one * 0.67,

    get_availability = function(self, entity)
      local target = State.grids.solids:safe_get(entity.position + Vector[entity.direction])
      return entity.turn_resources.actions > 0 and -Query(target).hp
    end,
    _run = function(self, entity)
      local target = State.grids.solids:safe_get(entity.position + Vector[entity.direction])
      entity.turn_resources.actions = entity.turn_resources.actions - 1
      base_attack(entity, target)
      return true
    end
  }
)

actions.move = {
  codename = "move",
  get_availability = function(self, entity)
    return entity.turn_resources.movement > 0
  end,
  _run = function(_, entity)
    local old_position = entity.position
    if not level.move(State.grids[entity.layer], entity, entity.position + Vector[entity.direction]) then
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
        base_attack(e, entity)
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

actions.dash = {
  codename = "dash",
  get_availability = function(self, entity)
    return entity.turn_resources.actions > 0
  end,
  _run = function(_, entity)
    entity.turn_resources.actions = entity.turn_resources.actions - 1
    entity.turn_resources.movement = entity.turn_resources.movement + entity:get_resources("move").movement
  end,
}

actions.interact = {
  codename = "interact",
  get_availability = function(self, entity)
    return entity.turn_resources.bonus_actions > 0
      and interactive.get_for(entity)
  end,
  _run = function(_, entity)
    local entity_to_interact = interactive.get_for(entity)
    if not entity_to_interact then return end
    if entity_to_interact.position ~= entity.position and not entity_to_interact.hp then
      entity:animate("attack")
    end
    entity.turn_resources.bonus_actions = entity.turn_resources.bonus_actions - 1
    entity_to_interact:interact(entity)
  end
}

actions.finish_turn = {
  codename = "finish_turn",
  get_availability = function() return true end,
  _run = function(_, entity)
    return combat.TURN_END_SIGNAL
    -- TODO maybe discard that and use a direct call to State.combat?
  end,
}

actions.list = {
  actions.move,
  actions.hand_attack,
  actions.interact,
  actions.dash,
}

return actions
