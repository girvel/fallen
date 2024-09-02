local gui = require("tech.gui")


local healing, module_mt, static = Module("mech.healing")

healing.heal = function(target, amount)
  target.hp = math.min(target:get_max_hp(), target.hp + amount)
  State:add(gui.floating_damage("+" .. amount, target.position, Colors.light_green()))
end

return healing
