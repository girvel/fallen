local level = require("tech.level")
local item = require("tech.item")


local module = {}
local module_mt = {}
setmetatable(module, module_mt)

module_mt.__call = function(_, systems, debug_mode)
	return {
    -- grids
    -- rails
    world = Tiny.world(unpack(systems)),
    grids = nil,
    collision_map = nil,
    collision_jgrid = nil,
    transform = 4,
    camera = {position = Vector.zero},

    debug_mode = debug_mode,

    CELL_DISPLAY_SIZE = 16,
    SCALING_FACTOR = 4,

    gui = require("tech.stateful.gui")(),

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

    add_multiple = function(self, list)
      return Fun.iter(list)
        :map(function(e) return self:add(e) end)
        :totable()
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

    remove_multiple = function(self, list)
      return Fun.iter(list)
        :map(function(e) return self:remove(e) end)
        :totable()
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

      self.collision_map = Fun.range(level_size[2])
        :map(function() return {} end)
        :totable()

      for _, entity in ipairs(new_entities) do
        local e = self:add(entity)
        if e.player_flag then self.player = e end
        if e.on_load then e:on_load(self) end
      end

      if love.filesystem.getInfo(path .. "/rails.lua") then
        self.rails = require(path .. "/rails")()
        self.rails:initialize(self)
      end

      self.gui.sidebar:update_action_grid()
      self.gui.sidebar:create_gui_entities()
    end,

    MODES = {"free", "fight", "dialogue", "dialogue_options", "reading", "death"},

    get_mode = function(self)
      if self.player.hp <= 0 then
        return "death"
      elseif self.gui.wiki.text_entities then
        return "reading"
      elseif self.gui.dialogue.options then
        return "dialogue_options"
      elseif self.gui.dialogue.text_entities then
        return "dialogue"
      elseif self.move_order then
        return "fight"
      else
        return "free"
      end
    end,
	}
end

return module
