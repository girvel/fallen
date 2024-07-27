local fighter = require("mech.classes.fighter")


return {
  ability = {
    strength = "сила",
    dexterity = "ловкость",
    constitution = "телосложение",
    intelligence = "интеллект",
    wisdom = "мудрость",
    charisma = "харизма",
  },

  build = {
    [fighter.fighting_style] = {
      two_handed_style = "бой двуручным оружием",
      duelist = "дуэлянт",
    },
  },

  perks = {
    [fighter.fighting_style] = "стиль боя",
  },

  race = {
    human = "Человек",
    variant_human_1 = "Человек (вариант) +1/+1",
    variant_human_2 = "Человек (вариант) +2",
  },
}
