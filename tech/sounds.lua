local sound = require("tech.sound")


local sounds, module_mt, static = Module("tech.sounds")

sounds.click = sound.multiple("assets/sounds/click_retro", 0.05)

return sounds
