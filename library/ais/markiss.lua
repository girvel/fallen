local item = require("tech.item")
local tcod = require("tech.tcod")
local ai = require("tech.ai")
local railing = require("tech.railing")
local items = require("library.palette.items")
local hauler = require("library.ais.hauler")
local api = ai.api


local markiss, module_mt, static = Module("library.ais.markiss")

markiss.mode = Enum {
  paused = {"duration"},
  looping = {},
}

module_mt.__call = function(_)
  return {
    point_i = 1,

    _mode = markiss.mode.looping(),

    _last_path = nil,
    _next_path_i = 1,

    run = ai.async(function(self, entity)
      if State.combat then return end
      return self._modal_behaviours[self._mode.codename](self, entity)
    end, true),

    _modal_behaviours = {
      looping = function(self, entity)
        if not self._last_path then
          self._last_path = tcod
            .snapshot()
            :find_path(entity.position, hauler.get_point(self.point_i))
        end

        if self._next_path_i > #self._last_path then
          self._last_path = nil
          self._next_path_i = 1
          self._mode = markiss.mode.paused(math.random() + 3)

          self.point_i = Math.loopmod(self.point_i + 1, 2)
          if self.point_i == 2 then
            item.give(entity, State:add(items.coal()))
          else
            State:remove(entity.inventory.underhand)
            entity.inventory.underhand = nil
          end
          return
        end

        if not api.move(entity, self._last_path[self._next_path_i] - entity.position) then
          self._last_path = nil
          self._next_path_i = 1
          self._mode = markiss.mode.paused(1)
          return
        end
        self._next_path_i = self._next_path_i + 1

        if Random.chance(.05) then
          self._mode = markiss.mode.paused(math.random() * 2)
        end
      end,

      paused = function(self, entity)
        railing.api.wait_seconds(self._mode.duration)
        self._mode = markiss.mode.looping()
      end,
    },
  }
end

return markiss
