local module = Static.module("tests.resources.package")

module.fighter = Static("fighter", {
  subclasses = {
    battle_master = Static("fighter.subclasses.battle_master", {}),
  }
})

module.rogue = Static {
  subclasses = {
    theif = Static {},
  },
}

return module
