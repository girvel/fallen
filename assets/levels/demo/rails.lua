return {
  initialize = function(self, state)
    self.entities = {
      door = state.grids.solids[Vector({21, 13})],
      levers = Fun.iter({15, 16, 17, 18})
        :map(function(x) return state.grids.solids[Vector({x, 17})] end)
        :totable()
    }
  end,

  update = function(self, state, event)
    if not self.entities.door.is_open and Log.trace(Fun.iter(self.entities.levers)
      :enumerate()
      :map(function(i, lever) return lever.is_on and math.pow(2, 4 - i) or 0 end)
      :sum()) == 13
    then
      self.entities.door:open()
    end
  end,
}
