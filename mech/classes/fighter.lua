local static_sprite = require("tech.static_sprite")


local module_mt = {}
local fighter = setmetatable({}, module_mt)

fighter.second_wind = Tablex.extend(
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
)

fighter.action_surge = {
  run = function(entity)
    if entity.turn_resources.action_surge <= 0 then
      return
    end
    entity.turn_resources.action_surge = entity.turn_resources.action_surge - 1
    entity.turn_resources.actions = entity.turn_resources.actions + 1
  end,
}

module_mt.__call = function(_)
  return {
    hp_die = 10,
    save_proficiencies = Common.set({"strength", "constitution", "dexterity"}),
    _action_table = {
      {fighter.second_wind},
      {fighter.action_surge},
    },
    get_actions = function(self, level)
      return Fun.iter(self._action_table)
        :take_n(level)
        :reduce(Tablex.concat, {})
    end,
  }
end

return fighter
