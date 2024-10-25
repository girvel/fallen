local kernel = {}

kernel.initialize = function()
  -- error handler should be the first
  local old_errorhandler = love.errorhandler
  love.errorhandler = require("kernel.callbacks.errorhandler")

  require("kernel.globals")()

  --- Fallen's custom kernel-level data
  love._custom = {
    active_time = 0,
    frames_total = 0,

    key_repetition = {
      delays = {},
      id = {},
      delay = .3,
      rate = 5,
      specific_rates = {},
    },
  }

  --- Fallen's custom kernel-level logic
  love.custom = {
    --- @return number
    get_rate = function() return love._custom.key_repetition.rate end,

    --- @param key any
    --- @param value number
    --- @return nil
    set_key_rate = function(key, value)
      love._custom.key_repetition.specific_rates[key] = value
    end,

    --- @param filepath string
    --- @return nil
    plan_load = function(filepath)
      love._custom.load = filepath
    end,

    --- @param filepath string
    --- @return nil
    plan_save = function(filepath)
      love._custom.save = filepath
    end,

    old_errorhandler = old_errorhandler,
  }

  love.run = require("kernel.callbacks.run")
end

return kernel
