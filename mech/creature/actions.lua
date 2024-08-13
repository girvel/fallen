local level = require("state.level")
local attacking = require("mech.attacking")
local random = require("utils.random")
local mech = require("mech")
local hostility = require("mech.hostility")
local interactive = require("tech.interactive")
local combat = require("tech.combat")
local sound = require("tech.sound")


local actions, _, static = Module("mech.creature.actions")

actions.get_melee_attack_roll = function(entity, slot)
  local roll = D(20) + entity.proficiency_bonus

  local weapon = entity.inventory[slot]
  if not weapon then
    roll = roll + mech.get_modifier(entity.abilities.str)
  else
    roll = roll + weapon.bonus + mech.get_melee_modifier(entity, slot)
  end

  return entity:get_effect("modify_attack_roll", roll)
end

actions.get_melee_damage_roll = function(entity, slot)
  local weapon = entity.inventory[slot]
  if not weapon then
    return D.roll({}, mech.get_modifier(entity.abilities.str))
  end

  local roll
  if weapon.tags.versatile and not entity.inventory.other_hand then
    roll = D(weapon.damage_roll.dice[1].sides_n + 2)
  else
    roll = weapon.damage_roll
  end

  roll = roll + weapon.bonus

  if slot == "main_hand" then
    roll = roll + mech.get_melee_modifier(entity, slot)
  end

  return entity:get_effect("modify_damage_roll", roll, slot)
end

local whoosh = sound.multiple("assets/sounds/whoosh", 0.05)

local base_attack = function(entity, target, slot)
  State:register_aggression(entity, target)

  entity:rotate(Vector.name_from_direction((target.position - entity.position):normalized()))
  State.audio:play(entity, random.choice(whoosh))
  entity:animate(slot .. "_attack")
  entity:when_animation_ends(function()
    if not attacking.attack(
      entity, target,
      actions.get_melee_attack_roll(entity, slot),
      actions.get_melee_damage_roll(entity, slot)
    ) then return end

    if target and target.sounds and target.sounds.hit then
      State.audio:play(target, random.choice(target.sounds.hit))
    end

    if target.hardness and not -Query(entity).inventory[slot] then
      attacking.attack_save(entity, "con", target.hardness, D.roll({}, 1))
    end
  end)
end

actions.hand_attack = static {
  codename = "hand_attack",
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

actions.other_hand_attack = static {
  codename = "other_hand_attack",
  get_availability = function(self, entity)
    local target = State.grids.solids:safe_get(entity.position + Vector[entity.direction])
    return entity.resources.bonus_actions > 0 and -Query(target).hp and entity.inventory.other_hand
  end,
  _run = function(self, entity)
    local target = State.grids.solids:safe_get(entity.position + Vector[entity.direction])
    entity.resources.bonus_actions = entity.resources.bonus_actions - 1
    base_attack(entity, target, "other_hand")
    return true
  end
}

actions.move = static {
  codename = "move",
  get_availability = function(self, entity)
    return entity.resources.movement > 0
  end,
  _run = function(_, entity)
    local old_position = entity.position
    if not level.move(entity, entity.position + Vector[entity.direction]) then
      return false
    end

    entity.resources.movement = entity.resources.movement - 1

    Fun.iter(Vector.directions)
      :map(function(d) return State.grids.solids:safe_get(old_position + d) end)
      :filter(function(e)
        return e
          and e ~= entity
          and e.abilities
          and hostility.are_hostile(entity, e)
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

actions.dash = static {
  codename = "dash",
  get_availability = function(self, entity)
    return entity.resources.actions > 0
  end,
  _run = function(_, entity)
    entity.resources.actions = entity.resources.actions - 1
    entity.resources.movement = entity.resources.movement + entity:get_resources("move").movement
  end,
}

actions.interact = static {
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

actions.finish_turn = static {
  codename = "finish_turn",
  get_availability = function() return true end,
  _run = function(_, entity)
    return combat.TURN_END_SIGNAL
    -- TODO maybe discard that and use a direct call to State.combat?
  end,
}

actions.list = static {
  actions.move,
  actions.hand_attack,
  actions.other_hand_attack,
  actions.interact,
  actions.dash,
}

return actions
