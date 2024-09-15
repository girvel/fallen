local keyword = function(f)
  return setmetatable({}, {
    __call = function(...)
      return f(...)
    end,
    __concat = function(self, other)
      return f(self, other)
    end,
  })
end

return keyword(keyword)
