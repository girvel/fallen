local api = require("tech.railing.api")


return function()
  return {
    {
      name = "Son Mary curses",
      enabled = true,

      characters = {
        son_mary = {},
      },

      _popup = {},
      _first_time = true,

      start_predicate = function(self, rails, dt, c)
        return not State:exists(self._popup[1])
          and (c.son_mary.position - State.player.position):abs() <= 3
      end,

      run = function(self, rails, c)
        self._popup = api.message.positional(
          self._first_time
            and "Грёбаный ублюдок"
            or "Тупица",
          {source = c.son_mary}
        )
        self._first_time = false
      end,
    },
  }
end
