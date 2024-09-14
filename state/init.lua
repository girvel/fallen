local level = require("state.level")
local combat = require("tech.combat")
local abilities = require("mech.abilities")
local sprite = require("tech.sprite")


local module, module_mt, static = Module("state")

module_mt.__call = function(_, systems)
	local result = {
    -- grids
    -- rails
    world = Tiny.world(unpack(systems)),
    grids = nil,

    entities = {},
    dependencies = {},

    aggression_log = {},
    _next_aggression_log = {},

    factions = nil,

    shader = nil,

    set_shader = function(self, shader)
      Query(self.shader):deactivate()
      self.shader = shader
      love.graphics.setShader(-Query(shader).love_shader)
    end,

    add = function(self, entity, ...)
      Table.extend(entity, ...)
      self.world:add(entity)
      self.entities[entity] = true
      if entity.position and entity.layer then
        level.put(entity)
      end
      if entity.inventory then
        Fun.iter(entity.inventory)
          :each(function(slot, it) self:add(it) end)
      end
      Query(entity):on_add()
      return entity
    end,

    add_multiple = function(self, list)
      return Fun.iter(list)
        :map(function(e) return self:add(e) end)
        :totable()
    end,

    remove = function(self, entity)
      if not entity.boring_flag then
        Log.debug("State:remove(%s)" % Entity.name(entity))
      end
      self.world:remove(entity)
      self.entities[entity] = nil
      if entity.position and entity.layer then
        level.remove(entity)
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

    refresh = function(self, entity, ...)
      self.world:add(Table.extend(entity, ...))
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

    load_level = function(self, path)
      local level_data = require(path).load()

      self.grids = Fun.iter(level.GRID_LAYERS)
        :map(function(layer)
          return layer, Grid(
            level_data.size,
            level.GRID_COMPLEX_LAYERS[layer]
              and function() return {} end
              or nil
          )
        end)
        :tomap()

      for _, entity in ipairs(level_data.entities) do
        local e = self:add(entity)
        if e.player_flag then self.player = e end
        if e.on_load then e:on_load(self) end
      end

      if not self.player then
        error("Player entity not found when loading %q" % path)
      end

      self.rails = level_data.rails
      Query(self.rails):initialize(self)

      self.gui:initialize()
      self.background_dummy = State:add({
        sprite = sprite.image("assets/sprites/water_sketch_02.png"),
      })
    end,

    start_combat = function(self, list)
      local current_i = 1
      if State.combat then
        list = Fun.iter(list)
          :filter(function(e) return not Table.contains(State.combat.list, e) end)
          :totable()
          current_i = State.combat.current_i
      end

      Fun.iter(list):each(function(e)
        e.current_initiative = abilities.initiative_roll(e):roll()
      end)

      Table.concat(list, -Query(State.combat):iter_entities_only():totable())
      table.sort(list, function(a, b) return a.current_initiative > b.current_initiative end)

      self.combat = combat(list)
      self.combat.current_i = current_i
    end,

    register_aggression = function(self, source, target)
      table.insert(self._next_aggression_log, {source, target})
    end,

    check_aggression = function(self, source, target)
      return Fun.iter(self.aggression_log)
        :any(function(pair) return pair[1] == source and pair[2] == target end)
    end,
	}

  local modes = {
    "character_creator", "death", "reading", "dialogue_options", "dialogue", "free", "combat",
    "text_input",
  }

  result.gui = require("state.gui")()
  result.hotkeys = require("state.hotkeys")(modes)
  result.ambient = require("state.ambient")()
  result.mode = require("state.mode")(result.gui.views_order)

  return result
end

return module
