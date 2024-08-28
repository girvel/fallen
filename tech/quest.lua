local quest, module_mt, static = Module("tech.quest")

quest.COMPLETED = static .. setmetatable({}, {__tostring = function() return "quest.COMPLETED" end})
quest.FAILED = static .. setmetatable({}, {__tostring = function() return "quest.FAILED" end})
quest.SPECIAL_STAGES = static {quest.COMPLETED, quest.FAILED}

return quest
