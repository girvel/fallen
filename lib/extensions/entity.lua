local entityx = {}

entityx.is_over = function(position, entity)
  return position > entity.position and position < entity.position + entity.size
end

entityx.name = function(entity)
  return -Query(entity).name or -Query(entity).codename or "???"
end

return entityx
