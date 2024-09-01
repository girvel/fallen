local action = require("tech.action")
local level = require("state.level")
local attacking = require("mech.attacking")
local abilities = require("mech.abilities")
local hostility = require("mech.hostility")
local interactive = require("tech.interactive")
local combat = require("tech.combat")
local sound = require("tech.sound")


local actions, _, static = Module("mech.creature.actions")

actions.get_melee_attack_roll = function(entity, slot)
  local roll = D(20) + entity.proficiency_bonus

  local weapon = entity.inventory[slot]
  if not weapon then
    roll = roll + abilities.get_modifier(entity.abilities.str)
  else
    roll = roll + weapon.bonus + abilities.get_melee_modifier(entity, slot)
  end

  return entity:get_effect("modify_attack_roll", roll)
end

actions.get_melee_damage_roll = function(entity, slot)
  local weapon = entity.inventory[slot]
  if not weapon then
    return D.roll({}, abilities.get_modifier(entity.abilities.str))
  end

  local roll
  if weapon.tags.versatile and not entity.inventory.other_hand then
    roll = D(weapon.damage_roll.dice[1].sides_n + 2)
  else
    roll = weapon.damage_roll
  end

  roll = roll + weapon.bonus

  if slot == "main_hand" then
    roll = roll + abilities.get_melee_modifier(entity, slot)
  end

  return entity:get_effect("modify_damage_roll", roll, slot)
end

local whoosh = sound.multiple("assets/sounds/whoosh", 0.05)

local base_attack = function(entity, target, slot)
  entity:rotate(Vector.name_from_direction((target.position - entity.position):normalized()))
  State.audio:play(entity, Random.choice(whoosh))
  entity:animate(slot .. "_attack"):next(function()
    State:register_aggression(entity, target)

    if not attacking.attack(
      entity, target,
      actions.get_melee_attack_roll(entity, slot),
      actions.get_melee_damage_roll(entity, slot)
    ) then return end

    if target and target.sounds and target.sounds.hit then
      State.audio:play(target, Random.choice(target.sounds.hit))
    end

    if target.hardness and not -Query(entity).inventory[slot] then
      attacking.attack_save(entity, "con", target.hardness, D.roll({}, 1))
    end
  end)
end

actions.hand_attack = static .. action {
  codename = "hand_attack",
  cost = {
    actions = 1,
  },
  _get_availability = function(self, entity)
    local target = State.grids.solids:safe_get(entity.position + Vector[entity.direction])
    return -Query(target).hp
  end,
  _run = function(self, entity)
    local target = State.grids.solids:safe_get(entity.position + Vector[entity.direction])
    base_attack(entity, target, "main_hand")
    return true
  end
}

actions.other_hand_attack = static .. action {
  codename = "other_hand_attack",
  cost = {
    bonus_actions = 1,
  },
  _get_availability = function(self, entity)
    local target = State.grids.solids:safe_get(entity.position + Vector[entity.direction])
    return -Query(target).hp and entity.inventory.other_hand
  end,
  _run = function(self, entity)
    local target = State.grids.solids:safe_get(entity.position + Vector[entity.direction])
    base_attack(entity, target, "other_hand")
    return true
  end,
}

actions.move = static .. action {
  codename = "move",
  cost = {
    movement = 1,
  },
  run = function(_, entity)
    local old_position = entity.position
    if not level.move(entity, entity.position + Vector[entity.direction]) then
      return false
    end

    entity.resources.movement = entity.resources.movement - 1

    if not entity.disengaged_flag then
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
    end

    if entity.animate then
      entity.movement_flag = true
      entity:animate("move"):next(function()
        entity.movement_flag = nil
      end)
    end

    local tile = State.grids.tiles[entity.position]
    if tile and tile.sounds and tile.sounds.move then
      State.audio:play(tile, Random.choice(tile.sounds.move))
    end

    return true
  end,
}

actions.dash = static .. action {
  codename = "dash",
  cost = {
    actions = 1,
  },
  get_movement_bonus = function(self, entity)
    return entity:get_resources("move").movement
  end,
  _run = function(self, entity)
    entity.resources.movement = entity.resources.movement + self:get_movement_bonus(entity)
  end,
}

actions.interact = static .. action {
  codename = "interact",
  cost = {
    bonus_actions = 1,
  },
  _get_availability = function(self, entity)
    return interactive.get_for(entity)
  end,
  _run = function(_, entity)
    local entity_to_interact = interactive.get_for(entity)
    if not entity_to_interact then return end
    if entity_to_interact.position ~= entity.position
      and not entity_to_interact.hp
      and not -Query(entity.inventory).main_hand
    then
      entity:animate("main_hand_attack"):next(function()
        entity_to_interact:interact(entity)
      end)
    else
      entity_to_interact:interact(entity)
    end
  end
}

actions.disengage = static .. action {
  codename = "disengage",
  cost = {
    actions = 1,
  },
  _run = function(_, entity)
    entity.disengaged_flag = true
  end
}

actions.finish_turn = static .. action {
  codename = "finish_turn",
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
