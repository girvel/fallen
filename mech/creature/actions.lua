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

local get_melee_attack_roll = function(entity, slot)
  local roll = D(20) + entity.proficiency_bonus

  local weapon = entity.inventory[slot]
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

  return entity:get_effect("modify_attack_roll", roll)
end

local get_melee_damage_roll = function(entity, slot)
  if not entity.inventory[slot] then
    return D.roll({}, mech.get_modifier(entity.abilities.strength))
  end

  local ability_modifier = mech.get_modifier(
    entity.inventory[slot].tags.finesse
    and math.max(
      entity.abilities.strength,
      entity.abilities.dexterity
    )
    or entity.abilities.strength
  )

  local roll = entity.inventory[slot].damage_roll + entity.inventory[slot].bonus

  if slot == "main_hand" then
    roll = roll + ability_modifier
  end

  return entity:get_effect("modify_damage_roll", roll)
end

local whoosh = Common.volumed_sounds("assets/sounds/whoosh", 0.05)

local base_attack = function(entity, target, slot)
  State:register_agression(entity, target)

  entity:rotate(Vector.name_from_direction((target.position - entity.position):normalized()))
  State.audio:play(entity, random.choice(whoosh))
  entity:animate(slot .. "_attack")
  entity:when_animation_ends(function()
    if not attacking.attack(
      entity, target,
      get_melee_attack_roll(entity, slot),
      get_melee_damage_roll(entity, slot)
    ) then return end

    if target and target.sounds and target.sounds.hit then
      State.audio:play(target, random.choice(target.sounds.hit))
    end

    if target.hardness and not -Query(entity).inventory[slot] then
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
      return entity.resources.actions > 0 and -Query(target).hp
    end,
    _run = function(self, entity)
      local target = State.grids.solids:safe_get(entity.position + Vector[entity.direction])
      entity.resources.actions = entity.resources.actions - 1
      base_attack(entity, target, "main_hand")
      return true
    end
  }
)

actions.other_hand_attack = {
  codename = "other_hand_attack",
  get_availability = function(self, entity)
    local target = State.grids.solids:safe_get(entity.position + Vector[entity.direction])
    return entity.resources.bonus_actions > 0 and -Query(target).hp
  end,
  _run = function(self, entity)
    local target = State.grids.solids:safe_get(entity.position + Vector[entity.direction])
    entity.resources.bonus_actions = entity.resources.bonus_actions - 1
    base_attack(entity, target, "other_hand")
    return true
  end
}

actions.move = {
  codename = "move",
  get_availability = function(self, entity)
    return entity.resources.movement > 0
  end,
  _run = function(_, entity)
    local old_position = entity.position
    if not level.move(State.grids[entity.layer], entity, entity.position + Vector[entity.direction]) then
      return false
    end

    entity.resources.movement = entity.resources.movement - 1

    Fun.iter(Vector.directions)
      :map(function(d) return State.grids.solids:safe_get(old_position + d) end)
      :filter(function(e)
        return e
          and e ~= entity
          and e.abilities
          and mech.are_hostile(entity, e)
          and e.resources
          and e.resources.reactions > 0
        end)
      :each(function(e)
        e.resources.reactions = e.resources.reactions - 1
        base_attack(e, entity, "main_hand")
      end)

    if entity.animate then
      entity:animate("move")
    end

    local tile = State.grids.tiles[entity.position]
    if tile and tile.sounds and tile.sounds.move then
      State.audio:play(tile, random.choice(tile.sounds.move))
    end

    return true
  end,
}

actions.dash = {
  codename = "dash",
  get_availability = function(self, entity)
    return entity.resources.actions > 0
  end,
  _run = function(_, entity)
    entity.resources.actions = entity.resources.actions - 1
    entity.resources.movement = entity.resources.movement + entity:get_resources("move").movement
  end,
}

actions.interact = {
  codename = "interact",
  get_availability = function(self, entity)
    return entity.resources.bonus_actions > 0
      and interactive.get_for(entity)
  end,
  _run = function(_, entity)
    local entity_to_interact = interactive.get_for(entity)
    if not entity_to_interact then return end
    if entity_to_interact.position ~= entity.position and not entity_to_interact.hp then
      entity:animate("attack")
    end
    entity.resources.bonus_actions = entity.resources.bonus_actions - 1
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
  actions.other_hand_attack,
  actions.interact,
  actions.dash,
}

return actions
