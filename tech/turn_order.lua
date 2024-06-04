return function(list)
  return {
    list = list,
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
  }
end
