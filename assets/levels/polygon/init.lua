return {
  load = Fn.curry(
    require("tech.ldtk").load,
    "assets/levels/demo.ldtk",
    "polygon",
    {rails = "assets.levels.polygon.rails"}
  )
}
