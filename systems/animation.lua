local constants = require("tech.constants")


local animation, _, static = Module("systems.animation")

animation.system = static(Tiny.processingSystem({
  codename = "animation",
  base_callback = "update",
  filter = Tiny.requireAll("animation"),
  process = function(_, entity, dt)
    if entity.animation.paused then return end

    entity.animation.frame = entity.animation.frame
      + dt * constants.DEFAULT_ANIMATION_FPS * (entity.animation_rate or 1)

    -- TODO a lot of unnecessary calls
    if not entity.animation.current
      or math.floor(entity.animation.frame) > #entity.animation.current
    then
      entity:animate("idle")
    end

    entity:animation_refresh()
  end,
}))

return animation
