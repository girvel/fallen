Static.module("tests.resources.package")

return Static {
  fighter = Static("fighter", {
    subclasses = {
      battle_master = Static("fighter.subclasses.battle_master", {}),
    }
  }),

  rogue = Static {
    subclasses = {
      theif = Static {},
    },
  },
}
