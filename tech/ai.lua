local turn_order = require("tech.turn_order")


return {
  async = function(fun)
    return function(self, event)
      local dt = unpack(event)
      if not Common.period(self, .25, dt) then return end
      if not self._ai_coroutine then
        self._ai_coroutine = coroutine.create(fun)
      end

      Common.resume_logged(self._ai_coroutine, self, dt)

      if coroutine.status(self._ai_coroutine) == "dead" then
        self._ai_coroutine = nil
        return turn_order.TURN_END_SIGNAL
      end
    end
  end,
}
