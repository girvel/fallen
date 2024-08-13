local FPS = 6

local animation, _, static = Module("systems.animation")

animation.system = static(Tiny.processingSystem({
  codename = "animation",
  base_callback = "update",
  filter = Tiny.requireAll("animation"),
  process = function(_, entity, event)
    local dt = unpack(event)
    local this_animation = entity.animation
    if this_animation.paused then return end
    this_animation.frame = this_animation.frame + dt * FPS

    if math.floor(this_animation.frame) == -Query(this_animation.pack[this_animation.current]):qlength() then
      if entity._on_animation_end then
        entity:_on_animation_end()
        entity._on_animation_end = nil
      end
    end

    if not this_animation.pack[this_animation.current]
      or math.floor(this_animation.frame) > #this_animation.pack[this_animation.current]
    then
      entity:animate("idle")
    end

    entity:animation_refresh()
  end,
}))

return animation
