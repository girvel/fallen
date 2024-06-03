local special = require("special")


local module = {}

module.damage = function(target, state, damage_roll, is_critical)
  local damage = math.max(0, damage_roll)
  Log.info("damage: " .. damage)

  if is_critical then
    state:add(special.floating_damage(damage .. "!", target.position))
  else
    state:add(special.floating_damage(damage, target.position))
  end

  target.hp = target.hp - damage
  if target.hp <= 0 then
    state:remove(target)
    Log.info(target.name .. " is killed")
  end
end

return module
