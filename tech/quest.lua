local quest, module_mt, static = Module("tech.quest")

quest.COMPLETED = 1000000
quest.FAILED = 1000001
quest.SPECIAL_STAGES = static {quest.COMPLETED, quest.FAILED}

return quest
