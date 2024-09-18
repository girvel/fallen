return Keyword .. function(_, constructor)
  return Keyword .. function(this_type, ...)
    local result = constructor(this_type, ...)
    result.__type = this_type
    return result
  end
end
