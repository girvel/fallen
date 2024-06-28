local level = require("tech.level")
local special = require("tech.special")


local module = {}
local module_mt = {}
setmetatable(module, module_mt)

module_mt.__call = function()
  local SCALING_FACTOR = 2
  local transform = love.math.newTransform()
  transform:scale(SCALING_FACTOR)

	return {
    -- grids
    -- rails
    world = Tiny.world(unpack(require("systems"))),
    transform = transform,
    camera = {position = Vector.zero},

    CELL_DISPLAY_SIZE = 16,
    SCALING_FACTOR = SCALING_FACTOR,

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
      local level_size, new_entities = level.load_entities(
        love.filesystem.read(path .. "/grid.txt"),
        require(path .. "/grid_args"),
        palette
      )

      self.grids = Fun.iter(level.GRID_LAYERS)
        :map(function(layer) return layer, Grid(level_size) end)
        :tomap()

      for _, entity in ipairs(new_entities) do
        local e = self:add(entity)
        if e.player_flag then self.player = e end
        if e.on_load then e:on_load(self) end
      end

      self.rails = require(path .. "/rails")
      self.rails:initialize(self)
    end,

    gui = {
      font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 12),
      show_page = function(self, path)
        local content = love.filesystem.read(path)
        self.text_entities = {
          State:add(special.text(content, self.font, Vector({0, 0})))
        }
      end,
      exit_wiki = function(self)
        if not self.text_entities then return end
        for _, e in ipairs(self.text_entities) do
          State:remove(e)
        end
        self.text_entities = nil
      end,
    }
	}
end

return module
