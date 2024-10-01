local translation = require("tech.translation")
local experience = require("mech.experience")
local action = require("tech.action")
local abilities = require("mech.abilities")
local healing = require("mech.healing")


local class, _, static = Module("mech.class")

class.choice = static .. Type .. function(_, t)
  assert(t.options)
  return t
end

class.provide_action = static .. function(self, entity, base)
  table.insert(base, self.action)
  return base
end

local ability_bonus_ids = Fun.iter(abilities.list)
  :map(function(a) return a, {} end)
  :tomap()

local concrete_ability_bonus = function(this_ability, bonus)
  return {
    name = translation.abilities[this_ability],
    id = ability_bonus_ids[this_ability],
    modify_ability_score = function(self, entity, score, ability)
      if ability == this_ability then
        score = score + bonus
      end
      return score
    end,
  }
end

class.ability_bonus = static .. function(bonus)
  return class.choice {
    name = "%+i" % bonus,
    options = Fun.iter(abilities.list)
      :map(function(a) return concrete_ability_bonus(a, bonus) end)
      :totable(),
  }
end

class.universal_ability_bonus = static .. function(bonus)
  return {
    name = "%+i ко всем характеристикам" % bonus,

    modify_ability_score = function(self, entity, score)
      return score + bonus
    end,
  }
end

local skill_proficiency_ids = Fun.iter(abilities.skills)
  :map(function(s) return s, {} end)
  :tomap()

local concrete_skill_proficiency = function(skill)
  return {
    name = translation.skill[skill],
    id = skill_proficiency_ids[skill],

    -- TODO! implement effect call
    modify_skill_score = function(self, entity, score)
      return score + experience.get_proficiency_modifier(entity.level)
    end,
  }
end

class.skill_proficiency = static .. function(skill_list)
  return class.choice {
    name = "навык",
    options = Fun.iter(skill_list)
      :map(concrete_skill_proficiency)
      :totable(),
  }
end

class.is_equivalent = static .. function(perk1, perk2)
  if perk1 == perk2 then return true end
  local id1 = -Query(perk1).id
  local id2 = -Query(perk2).id
  return id1 and id2 and id1 == id2
end

class.hit_dice = static {
  codename = "hit_dice",
  hidden = true,

  action = static .. action {
    get_healing_roll = function(self, entity)
      return D(entity.class.hp_die) + entity:get_modifier("con")
    end,
    cost = {
      hit_dice = 1,
    },
    _get_availability = function(self, entity)
      return entity.hp < entity:get_max_hp()
    end,
    _run = function(self, entity)
      healing.heal(entity, self:get_healing_roll(entity):roll())
    end,
  },

  modify_resources = function(self, entity, base, rest_type)
    if rest_type == "long" then
      base.hit_dice = entity.level
    end
    return base
  end,

  modify_actions = class.provide_action,
}

class.save_proficiency = function(...)
  return {
    _abilities = Common.set {...},
    codename = "save_proficiency",
    hidden = true,
    modify_saving_throw = function(self, entity, roll, ability)
      if self._abilities[ability] then
        roll = roll + experience.get_proficiency_modifier(entity.level)
      end
      return roll
    end
  }
end

return class
