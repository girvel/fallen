local common = require("utils.common")


local module = {}
local module_mt = {}
setmetatable(module, module_mt)

module.GRID_LAYERS = {"tiles", "solids", "sfx"}

module_mt.__call = function()
  local transform = love.math.newTransform()
  transform:scale(2)

	return {
    -- grids
    -- rails
    world = Tiny.world(unpack(require("systems"))),
    transform = transform,
    camera = {position = Vector.zero},
    CELL_DISPLAY_SIZE = 16,

    add = function(self, entity)
      self.world:add(entity)
      if entity.position then
        self.grids[entity.layer][entity.position] = entity
      end
      return entity
    end,

    remove = function(self, entity)
      self.world:remove(entity)

      if entity.position then
        self.grids[entity.layer][entity.position] = nil
      end

      if self.move_order then
        self.move_order:remove(entity)
      end
    end,

    load_level = function(self, path, palette)
      local level_lines = love.filesystem.read(path .. "/grid.txt"):split("\n")
      local level_size = Vector({#level_lines[1], #level_lines})

      local grid_of_args = Grid(level_size)
      for k, v in pairs(loadstring(love.filesystem.read(path .. "/grid_args.lua"))()) do
        grid_of_args[Vector(k)] = v
      end

      self.grids = Fun.iter(module.GRID_LAYERS)
        :map(function(layer) return layer, Grid(level_size) end)
        :tomap()

      for _, layer in ipairs(module.GRID_LAYERS) do
        for y, line in ipairs(level_lines) do
          for _, x, character in Fun.iter(line):enumerate() do
            local factory = (palette[layer] or {})[character]
            if factory then
              local position = Vector({x, y})
              local e = self:add(common.extend(
                factory(unpack(grid_of_args[position] or {})),
                {position = position, layer = layer}
              ))

              if character == "@" then
                self.player = e
              end
              if e.on_load then e:on_load(self) end
            end
          end
        end
      end

      self.rails = loadstring(love.filesystem.read(path .. "/rails.lua"))()
      self.rails:initialize(self)
    end,
	}
end

return module
