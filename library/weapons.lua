local module = {}

module.rapier = function()
  return {
    name = "рапира",
    damage_roll = D(8),
    is_finesse = true,
    bonus = 0,
  }
end

return module
