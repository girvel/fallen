local kernel = {}

kernel.initialize = function()
  require("kernel.globals")()
  love.run = require("kernel.callbacks.run")

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

  love.custom = {
    get_rate = function() return love._custom.key_repetition.rate end,

    set_key_rate = function(key, value)
      love._custom.key_repetition.specific_rates[key] = value
    end,

    load = function(filepath)
      love._custom.load = filepath
    end,

    save = function(filepath)
      love._custom.save = filepath
    end,
  }
end

return kernel
