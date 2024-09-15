return Keyword .. function(_, constructor)
  return Keyword .. function(self, ...)
    local result = constructor(...)
    result.__type = self
    return result
  end
end
