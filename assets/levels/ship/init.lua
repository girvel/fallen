return {
  load = Fn.curry(
    require("tech.ldtk").load,
    "assets/levels/demo.ldtk",
    "ship",
    {rails = "assets.levels.ship.rails"}
  )
}
