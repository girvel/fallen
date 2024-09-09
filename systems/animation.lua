local FPS = 6

local animation, _, static = Module("systems.animation")

animation.system = static(Tiny.processingSystem({
  codename = "animation",
  base_callback = "update",
  filter = Tiny.requireAll("animation"),
  process = function(_, entity, dt)
    local this_animation = entity.animation
    if this_animation.paused then return end

    local rate = FPS * (entity.animation_rate or 1)
    this_animation.frame = this_animation.frame + dt * rate

    if not this_animation.current
      or math.floor(this_animation.frame) > #this_animation.current
    then
      entity:animate("idle")
    end

    entity:animation_refresh()
  end,
}))

return animation
