local level = require("tech.level")
local item = require("tech.item")


local module = {}
local module_mt = {}
setmetatable(module, module_mt)

module_mt.__call = function(_, systems, debug_mode)
  local SCALING_FACTOR = 4
  local transform = love.math.newTransform()
  transform:scale(SCALING_FACTOR)

	return {
    -- grids
    -- rails
    world = Tiny.world(unpack(systems)),
    transform = transform,
    camera = {position = Vector.zero},

    debug_mode = debug_mode,

    CELL_DISPLAY_SIZE = 16,
    SCALING_FACTOR = SCALING_FACTOR,

    gui = require("tech.stateful.gui"),

    add = function(self, entity)
      self.world:add(entity)
      if entity.position and entity.layer then
        self.grids[entity.layer][entity.position] = entity
      end
      if entity.inventory then
        Fun.iter(item.SLOTS)
          :map(function(slot) return entity.inventory[slot] end)
          :filter(function(it) return it end)
          :each(function(it) self:add(it) end)
      end
      return entity
    end,

    remove = function(self, entity)
      self.world:remove(entity)
      if entity.position and entity.layer then
        self.grids[entity.layer][entity.position] = nil
      end
      if self.move_order then
        self.move_order:remove(entity)
      end
      Query(entity):on_remove()
      return entity
    end,

    refresh = function(self, entity)
      self.world:add(entity)
    end,

    exists = function(self, entity)
      return self.world.entities[entity]
    end,

    load_level = function(self, path, palette)
      local level_size, new_entities = level.load_entities(
        love.filesystem.read(path .. "/grid.txt"),
        love.filesystem.getInfo(path .. "/grid_args.lua") and require(path .. "/grid_args") or {},
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

      if love.filesystem.getInfo(path .. "/rails.lua") then
        self.rails = require(path .. "/rails")()
        self.rails:initialize(self)
      end

      self.gui:update_action_grid()
      self.gui:create_gui_entities()
    end,
	}
end

return module
