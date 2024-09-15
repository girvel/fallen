local fighter = require("mech.classes.fighter")
local feats = require("mech.feats")


return Module("tech.translation", {
  abilities = {
    str = "сила",
    dex = "ловкость",
    con = "телосложение",
    int = "интеллект",
    wis = "мудрость",
    cha = "харизма",
  },

  skill = {
    sleight_of_hand = "ловкость рук",
    stealth = "скрытность",
    arcana = "магия",
    history = "история",
    investigation = "расследование",
    nature = "природа",
    religion = "религия",
    animal_handling = "уход за животными",
    insight = "проницательность",
    medicine = "медицина",
    perception = "внимание",
    deception = "обман",
    intimidation = "запугивание",
    performance = "выступление",
    persuasion = "убеждение",
  },

  -- TODO! RM
  -- build = {
  --   [fighter.fighting_style] = {
  --     two_handed_style = "бой двуручным оружием",
  --     duelist = "дуэлянт",
  --     two_weapon_fighting = "бой двумя оружиями",
  --   },
  --   [feats.perk] = {
  --     savage_attacker = "свирепый атакующий",
  --     great_weapon_master = "мастер двуручного оружия",
  --   },
  -- },

  -- perks = {
  --   [fighter.fighting_style] = "стиль боя",
  --   [feats.perk] = "черта",
  -- },

  -- race = {
  --   human = "Человек",
  --   variant_human_1 = "Человек (вариант) +1/+1",
  --   variant_human_2 = "Человек (вариант) +2",
  -- },

  resources = {
    bonus_actions = "бонусные действия",
    movement = "движение",
    reactions = "реакции",
    actions = "действия",
    second_wind = "второе дыхание",
    action_surge = "всплеск действий",
    hit_dice = "перевязать раны",
    fighting_spirit = "боевой дух",
  },

  class = {
    fighter = "воин",
  },

  items = {
    tags = {
      two_handed = "двуручное",
      light = "лёгкое",
      finnesse = "фехтовальное",
      heavy = "тяжёлое",
      versatile = "полуторное",
    },
  },
})
