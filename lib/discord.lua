local ffi = require("ffi")

local header = love.filesystem.read("lib/vendor/discord_game_sdk/discord_game_sdk.h")
ffi.cdef(header)
local raw = Common.load_c_library("discord_game_sdk/x86_64/discord_game_sdk")

local module_mt = {}
local discord = setmetatable({}, module_mt)

module_mt.__call = function(_)
  local params = ffi.new("struct DiscordCreateParams[1]")
  ffi.fill(params, ffi.sizeof("struct DiscordCreateParams"), 0)
  params[0].application_version = 1
  params[0].user_version = 1
  params[0].image_version = 1
  params[0].activity_version = 1
  params[0].relationship_version = 1
  params[0].lobby_version = 1
  params[0].network_version = 1
  params[0].overlay_version = 2
  params[0].storage_version = 1
  params[0].store_version = 1
  params[0].voice_version = 1
  params[0].achievement_version = 1

  params[0].client_id = 1282966796533501953
  params[0].flags = 1

  ffi.cdef [[
    struct Application {
      struct IDiscordCore *core;
      struct IDiscordUsers *users;
    }
  ]]

  Log.trace(3)

  local app = ffi.new("struct Application *")
  Log.trace(3.25)
  ffi.fill(app, ffi.sizeof("struct Application"), 0)


  local events = ffi.new("struct IDiscordCoreEvents *")
  ffi.fill(events, ffi.sizeof("struct IDiscordCoreEvents"), 0)

  params[0].events = events
  params[0].event_data = app

  local result = ffi.new("struct IDiscordCore **") -- TODO should point to app field

  Log.trace(4)
  raw.DiscordCreate(3, params, result)

  Log.trace(5)
  return result[0]
end

return discord
