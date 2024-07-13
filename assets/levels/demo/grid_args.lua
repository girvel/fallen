local weapons = require("library.weapons")


return {
  [{7, 12}] = {true},
  [{7, 9}] = {"down", {main_hand = weapons.gas_key()}},
  [{5, 8}] = {"down"},
  [{5, 3}] = {"left", {gloves = weapons.yellow_glove()}},
  [{8, 3}] = {"up"},
}
