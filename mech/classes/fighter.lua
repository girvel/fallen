local module_mt = {}
local module = setmetatable({}, module_mt)

module_mt.__call = function(_)
  return {
    hp_die = 10,
    save_proficiencies = Common.set({"strength", "constitution", "dexterity"}),
  }
end

return module
