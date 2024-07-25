local static_sprite = require("tech.static_sprite")


local module_mt = {}
local fighter = setmetatable({}, module_mt)

fighter.second_wind = Tablex.extend(
  static_sprite("assets/sprites/icons/second_wind.png"),
  {
    codename = "second_wind",
    size = Vector.one * 0.67,
    on_click = function(self, entity) return entity:act(self) end,
    get_availability = function(self, entity)
      return entity.resources.bonus_actions > 0
        and entity.resources.second_wind > 0
    end,
    _run = function(self, entity)
      entity.resources.bonus_actions = entity.resources.bonus_actions - 1
      entity.resources.second_wind = entity.resources.second_wind - 1

      entity.hp = math.min(entity:get_max_hp(), entity.hp + (D(10) + entity.level):roll())
    end,
  }
)

fighter.action_surge = {
  codename = "action_surge",
  get_availability = function(self, entity)
    return entity.resources.action_surge > 0
  end,
  _run = function(self, entity)
    entity.resources.action_surge = entity.resources.action_surge - 1
    entity.resources.actions = entity.resources.actions + 1
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
    _resource_table = {
      {short = {second_wind = 1}},
      {short = {action_surge = 1}},
    },
    get_resources = function(self, level, rest_type)
      return Fun.iter(self._resource_table)
        :take_n(level)
        :map(function(t) return t[rest_type] end)
        :reduce(Tablex.extend, {})
    end,
  }
end

return fighter