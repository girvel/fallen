local FPS = 6

return Tiny.processingSystem({
  base_callback = "update",
  filter = Tiny.requireAll("animation"),
  process = function(_, entity, _, event)
    local dt = unpack(event)
    local animation = entity.animation
    animation.frame = animation.frame + dt * FPS

    if not animation.pack[animation.current] or math.floor(animation.frame) > #animation.pack[animation.current] then
      entity:animate("idle")

      if entity._on_end then
        entity:_on_end()
        entity._on_end = nil
      end
    end

    entity.sprite.image = animation.pack[animation.current][math.floor(animation.frame)]
  end,
})
