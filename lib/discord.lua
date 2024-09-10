local ffi = require("ffi")

local header = love.filesystem.read("lib/vendor/discord_game_sdk/discord_game_sdk_clean.h")
ffi.cdef(header)
local raw = Common.load_c_library("discord_game_sdk/x86_64/discord_game_sdk")

local module_mt = {}
local discord = setmetatable({}, module_mt)

module_mt.__call = function(_)
  local result = ffi.new("struct IDiscordCore[1][1]")
  raw.DiscordCreate(nil, nil, result)
  return result[0]
end

return discord
