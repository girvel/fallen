local animated = require("tech.animated")


return animated.load_pack("assets/sprites/humanoid", {
  idle_right = {
    {
      main_hand = Vector({3, 12}),
      gloves = Vector({3, 12}),
    },
  },
  idle_left = {
    {
      main_hand = Vector({11, 12}),
      gloves = Vector({11, 12}),
    },
  },
  idle_down = {
    {
      main_hand = Vector({3, 12}),
      gloves = Vector({3, 12}),
    },
  },
  idle_up = {
    {
      main_hand = Vector({11, 12}),
      gloves = Vector({11, 12}),
    },
  },
  attack_right = {
    {
      main_hand = Vector({2, 12}),
      gloves = Vector({2, 12}),
    },
    {
      main_hand = Vector({14, 11}),
      gloves = Vector({14, 11}),
    },
  },
  attack_left = {
    {
      main_hand = Vector({12, 12}),
      gloves = Vector({12, 12}),
    },
    {
      main_hand = Vector({0, 11}),
      gloves = Vector({0, 11}),
    },
  },
  attack_down = {
    {
      main_hand = Vector({3, 11}),
      gloves = Vector({3, 11}),
    },
    {
      main_hand = Vector({3, 15}),
      gloves = Vector({3, 15}),
    },
  },
  attack_up = {
    {
      main_hand = Vector({11, 13}),
      gloves = Vector({11, 13}),
    },
    {
      main_hand = Vector({11, 8}),
      gloves = Vector({11, 8}),
    },
  },
  move_right = {
    {
      main_hand = Vector({3, 12}),
      gloves = Vector({3, 12}),
    },
    {
      main_hand = Vector({3, 12}),
      gloves = Vector({3, 12}),
    },
    {
      main_hand = Vector({3, 12}),
      gloves = Vector({3, 12}),
    },
  },
  move_left = {
    {
      main_hand = Vector({11, 12}),
      gloves = Vector({11, 12}),
    },
    {
      main_hand = Vector({11, 12}),
      gloves = Vector({11, 12}),
    },
    {
      main_hand = Vector({11, 12}),
      gloves = Vector({11, 12}),
    },
  },
  move_down = {
    {
      main_hand = Vector({3, 12}),
      gloves = Vector({3, 12}),
    },
    {
      main_hand = Vector({3, 12}),
      gloves = Vector({3, 12}),
    },
    {
      main_hand = Vector({3, 12}),
      gloves = Vector({3, 12}),
    }
  },
  move_up = {
    {
      main_hand = Vector({11, 12}),
      gloves = Vector({11, 12}),
    },
    {
      main_hand = Vector({11, 12}),
      gloves = Vector({11, 12}),
    },
    {
      main_hand = Vector({11, 12}),
      gloves = Vector({11, 12}),
    },
  },
})
