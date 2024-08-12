local special = require("tech.special")


local healing, module_mt, static = Module("mech.healing")

healing.heal = function(target, amount)
  target.hp = math.min(target:get_max_hp(), target.hp + amount)
  State:add(special.floating_damage("+" .. amount, target.position, Common.hex_color("b3daa3")))
end

return healing
