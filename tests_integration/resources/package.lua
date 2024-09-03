local module, _, static = Module("tests.resources.package")

module.fighter = static {
  subclasses = {
    battle_master = static {},
  }
}

module.rogue = static {
  subclasses = {
    theif = static {},
  },
}

return module
