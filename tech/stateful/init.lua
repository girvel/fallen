local level = require("tech.level")
local item = require("tech.item")
local combat = require("tech.combat")
local mech = require("mech")


local module = {}
local module_mt = {}
setmetatable(module, module_mt)

module_mt.__call = function(_, systems, debug_mode)
  local modes = {
    "character_creator", "death", "reading", "dialogue_options", "dialogue", "free", "combat",
  }

	return {
    -- grids
    -- rails
    world = Tiny.world(unpack(systems)),
    grids = nil,
    transform = 4,
    camera = {position = Vector.zero},

    debug_mode = debug_mode,

    SCALING_FACTOR = 4,
    MODES = modes,

    gui = require("tech.stateful.gui")(),
    hotkeys = require("tech.stateful.hotkeys")(modes, debug_mode),

    entities = {},
    dependencies = {},

    agression_log = {},
    _next_agression_log = {},

    add = function(self, entity)
      self.world:add(entity)
      self.entities[entity] = true
      if entity.position and entity.layer then
        self.grids[entity.layer][entity.position] = entity
      end
      if entity.inventory then
        Fun.iter(item.SLOTS)
          :map(function(slot) return entity.inventory[slot] end)
          :filter(Fun.op.truth)
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
      if not entity.boring_flag then
        Log.debug("State:remove(%s)" % Common.get_name(entity))
      end
      self.world:remove(entity)
      self.entities[entity] = nil
      if entity.position and entity.layer then
        self.grids[entity.layer][entity.position] = nil
      end
      if self.combat then
        self.combat:remove(entity)
      end
      Query(entity):on_remove()
      Fun.iter(self.dependencies[entity] or {})
        :each(function(e) return self:remove(e) end)
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
      return self.entities[entity]
    end,

    add_dependency = function(self, parent, child)
      if not self.dependencies[parent] then
        self.dependencies[parent] = {}
      end
      table.insert(self.dependencies[parent], child)
    end,

    load_level = function(self, path, palette)
      local level_size, new_entities, player_anchor = level.load_entities(
        love.filesystem.read(path .. "/grid.txt"),
        love.filesystem.getInfo(path .. "/grid_args.lua") and require(path .. "/grid_args") or {},
        palette
      )

      self.gui.character_creator.player_anchor = player_anchor

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

      self.gui.sidebar:create_gui_entities()

      if not self.player then
        self.gui.character_creator:refresh()
      end
    end,

    get_mode = function(self)
      if not self.player then
        return "character_creator"
      elseif self.player.hp <= 0 then
        return "death"
      elseif self.gui.wiki.text_entities then
        return "reading"
      elseif self.gui.dialogue.options then
        return "dialogue_options"
      elseif self.gui.dialogue.text_entities then
        return "dialogue"
      elseif self.combat then
        return "combat"
      else
        return "free"
      end
    end,

    start_combat = function(self, list)
      local initiative_rolls = Fun.iter(list)
        :map(function(e)
          return {
            entity = e,
            roll = (D(20) + mech.get_modifier(e.abilities.dexterity)):roll()
          }
        end)
        :totable()

      table.sort(initiative_rolls, function(a, b) return a.roll > b.roll end)

      local pure_order = Fun.iter(initiative_rolls)
        :map(function(x) return x.entity end)
        :totable()

      self.combat = combat(pure_order)
    end,

    register_agression = function(self, source, target)
      table.insert(self._next_agression_log, {source, target})
    end,
	}
end

return module
