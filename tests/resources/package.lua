Const.module("tests.resources.package")

return Const {
  fighter = Const("fighter", {
    subclasses = {
      battle_master = Const("fighter.subclasses.battle_master", {}),
    }
  }),

  rogue = Const {
    subclasses = {
      theif = Const {},
    },
  },
}
