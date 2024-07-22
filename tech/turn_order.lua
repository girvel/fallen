local module_mt = {}
local module = setmetatable({}, module_mt)

module.TURN_END_SIGNAL = 666
module.WORLD_TURN = {codename = "WORLD_TURN"}

module_mt.__call = function(_, list)
  return {
    list = Fun.iter(list)
      :filter(function(e) return State:exists(e) end)
      :chain({module.WORLD_TURN})
      :totable(),
    current_i = 1,
    remove = function(self, item)
      self.list = Fun.iter(self.list)
        :enumerate()
        :filter(function(i, e)
          if e ~= item then return true end
          if i < self.current_i then self.current_i = self.current_i - 1 end
        end)
        :map(function(_, e) return e end)
        :totable()
    end,
    get_current = function(self)
      return self.list[self.current_i]
    end,
    move_to_next = function(self)
      self.current_i = self.current_i + 1
      if self.current_i > #self.list then
        self.current_i = 1
      end
    end,
  }
end

return module
