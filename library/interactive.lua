local common = require("utils.common")


local module = {}

module.get_for = function(entity, state)
  return Fun.iter({
    state.grids.tiles[entity.position],
    state.grids.solids:safe_get(entity.position + Vector[entity.direction]),
  })
    :filter(function(x) return x.interact end)
    :nth(1)
end

module.scripture_straight = function()
  return {
    name = "Scripture",
    was_interacted_with = false,
    interact = function(self, other, state)
      other.reads = "Hello, VSauce! Michael here.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

      self.was_interacted_with = true
      if self._highlight then
        state:remove(self._highlight)
        self._highlight = nil
      end
    end,
    on_load = function(self, state)
      self._highlight = state:add(common.extend(module.highlight(), {position = self.position}))
    end,
    sprite = {
      image = love.graphics.newImage("assets/sprites/scripture_straight.png")
    }
  }
end

return module
