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
  }
end

return kernel
