local weapons = require("library.weapons")


return {
  [{10, 15}] = {true},
  [{10, 10}] = {"down", {main_hand = weapons.gas_key()}},
  [{5, 9}] = {"down"},
  [{5, 4}] = {"left", {main_glove = weapons.yellow_glove()}},
  [{12, 3}] = {"up"},
}
