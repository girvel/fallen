return Tiny.processingSystem({
  base_callback = "update",
  filter = Tiny.requireAll("animation"),
  process = function(_, entity)
    local animation = entity.animation
    animation.frame = animation.frame + 1
    if not animation.pack[animation.current] or animation.frame > #animation.pack[animation.current] then
      animation.current = "idle"
      animation.frame = 1
    end
    Log.trace(animation.current, animation.frame)

    entity.sprite.image = animation.pack[animation.current][animation.frame]
  end,
})
