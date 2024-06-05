local common = require("utils.common")


local module = {}
local module_mt = {}
setmetatable(module, module_mt)

local GRID_LAYERS = {"tiles", "solids", "sfx"}

module_mt.__call = function()
	return {
    -- grids
    world = Tiny.world(unpack(require("systems"))),

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
      local level_lines = love.filesystem.read(path):split("\n")
      self.grids = Fun.iter(GRID_LAYERS)
        :map(function(layer) return layer, Grid(Vector({#level_lines[1], #level_lines})) end)
        :tomap()

      for _, layer in ipairs(GRID_LAYERS) do
        for y, line in ipairs(level_lines) do
          for _, x, character in Fun.iter(line):enumerate() do
            local factory = (palette[layer] or {})[character]
            if factory then
              local e = self:add(common.extend(factory(), {position = Vector({x, y}), layer = layer}))
              if character == "@" then
                self.player = e
              end
              if e.on_load then e:on_load(self) end
            end
          end
        end
      end
    end,
	}
end

return module
