local log = require("lib.log")


local direction_order = {
  up = 0,
  left = 1,
  down = 2,
  right = 3,
}

love.load = love.load or function(args)
  log.info("started", args)
  local canvases = {}
  for _, file_name in ipairs(love.filesystem.getDirectoryItems(args[1])) do
    log.info("loading", file_name)
    local break_i = file_name:find("%.png$")
    local frame_number_string = file_name:sub(break_i - 2, break_i - 1)
    local frame_number = tonumber(frame_number_string)
    local full_name
    if frame_number then
      full_name = file_name:sub(0, break_i - 4)
    else
      frame_number = 1
      frame_number_string = "01"
      full_name = file_name:sub(0, break_i - 1)
    end
    local _, _, name, direction = full_name:find("^(.*)_([^_]+)$")

    local image = love.graphics.newImage(args[1] .. "/" .. file_name)
    local new_name = name .. "_" .. frame_number_string .. ".png"
    if not canvases[new_name] then
      canvases[new_name] = love.graphics.newCanvas(image:getWidth() * 4, image:getHeight())
    end

    love.graphics.setCanvas(canvases[new_name])
    love.graphics.draw(image, direction_order[direction] * image:getWidth(), 0)
  end

  love.graphics.setCanvas()
  local new_directory = args[1] .. "_atlas"
  local info = love.filesystem.getInfo(new_directory) or {}
  if info.type == "file" then
    log.info("removing file", new_directory)
    love.filesystem.remove(new_directory)
  elseif info.type == "directory" then
    log.info("removing directory", new_directory)
    for _, name in ipairs(love.filesystem.getDirectoryItems(new_directory)) do
      love.filesystem.remove(new_directory .. "/" .. name)
    end
    love.filesystem.remove(new_directory)
  end
  love.filesystem.remove(new_directory)
  love.filesystem.createDirectory(new_directory)

  for name, canvas in pairs(canvases) do
    log.info("encoding", name)
    canvas:newImageData():encode("png", new_directory .. "/" .. name)
  end
  log.info("finished")
  love.event.push("quit")
end
