local animated = require("tech.animated")
local level = require("tech.level")
local combat = require("tech.combat")
local abilities = require("mech.abilities")
local sprite = require("tech.sprite")
local tcod   = require("tech.tcod")
local constants = require("tech.constants")


--- @overload fun(systems: table[]): state
local state, module_mt, static = Module("state")

--- @class state
--- @field player player
--- @field grids table<layer, grid>
--- @field factions table<string, table>
--- @field shader shader?
--- @field profiler table
--- @field rails table
--- @field background table
--- @field water_speed number
---
--- @field combat table?
--- @field gui state_gui
--- @field hotkeys table
--- @field ambient state_ambient
--- @field mode table
---
--- @field fast_scenes boolean
---
--- @field _world table
--- @field _entities {[entity]: boolean}
--- @field _dependencies {[entity]: entity[]}
--- @field _aggression_log [entity, entity][]
--- @field _next_aggression_log [entity, entity][]
local state_base = {
  --- Modifies entity
  --- @generic T: entity
  --- @param self state
  --- @param entity T
  --- @param ... table extensions
  --- @return T
  add = function(self, entity, ...)
    --- @cast entity entity

    Table.extend(entity, ...)
    self._world:add(entity)
    self._entities[entity] = true
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

  --- @generic T: table[]
  --- @param self state
  --- @param list T
  --- @return T
  add_multiple = function(self, list)
    return Fun.iter(list)
      :map(function(e) return self:add(e) end)
      :totable()
  end,

  --- @generic T: entity
  --- @param self state
  --- @param entity T
  --- @return T
  remove = function(self, entity)
    --- @cast entity entity
    if not entity.boring_flag then
      Log.debug("State:remove(%s)" % Entity.codename(entity))
    end

    self._world:remove(entity)
    self._entities[entity] = nil

    if entity.position and entity.layer then
      level.remove(entity)
    end

    for slot, item in pairs(entity.inventory or {}) do
      self:remove(item)
    end

    if self.combat then
      self.combat:remove(entity)
    end

    Query(entity):on_remove()

    Fun.iter(self._dependencies[entity] or {})
      :each(function(e) return self:remove(e) end)
    return entity
  end,

  --- @generic T: table[]
  --- @param self state
  --- @param list T
  --- @return T
  remove_multiple = function(self, list)
    return Fun.iter(list)
      :map(function(e) return self:remove(e) end)
      :totable()
  end,

  --- Modifies entity
  --- @generic T: table
  --- @param self state
  --- @param entity T
  --- @param ... table extensions
  --- @return T
  refresh = function(self, entity, ...)
    self._world:add(Table.extend(entity, ...))
    return entity
  end,

  --- @param self state
  --- @param entity table?
  --- @return boolean
  exists = function(self, entity)
    return self._entities[entity]
  end,

  --- Inactive
  add_dependency = function(self, parent, child)
    if not self._dependencies[parent] then
      self._dependencies[parent] = {}
    end
    table.insert(self._dependencies[parent], child)
  end,

  --- @param self state
  --- @param path string
  --- @return nil
  load_level = function(self, path)
    local level_data = require(path).load()

    self.water_speed = assert(
      level_data.water_speed,
      "water_speed for level %q is undefined" % path
    )

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

    self.grids.solids = tcod.observer(self.grids.solids)

    for _, entity in ipairs(level_data.entities) do
      local e = self:add(entity)
      if e.player_flag then self.player = e end
      if e.on_load then e:on_load(self) end
    end

    if not self.player then
      error("Player entity not found when loading %q" % path)
    end

    if level_data.rails then
      self.rails = level_data.rails
      Log.info("Initializing rails")
      self.rails:initialize(self)
      Log.info("Rails initialization finished")
    end

    self.gui:initialize()
    self.background = State:add(
      animated("assets/sprites/animations/water"),
      {
        _offset = Vector.zero,
        ai = {observe = function(self, entity, dt)
          entity._offset = (entity._offset + Vector.down * State.water_speed * dt)
            :map(function(it) return it % constants.CELL_DISPLAY_SIZE end)
        end},
      }
    )
  end,

  --- @param self state
  --- @param list entity[]
  --- @return nil
  start_combat = function(self, list)
    local current_i = 1
    if State.combat then
      list = Fun.iter(list)
        :filter(function(e) return not Table.contains(State.combat.list, e) end)
        :totable()
        current_i = State.combat.current_i
    end

    for _, e in ipairs(list) do
      e.last_initiative = abilities.initiative_roll(e):roll()
    end

    Table.concat(list, -Query(State.combat):iter_entities_only():totable())
    table.sort(list, function(a, b) return a.last_initiative > b.last_initiative end)

    self.combat = combat(list)
    self.combat.current_i = current_i
  end,

  --- @param self state
  --- @param source entity
  --- @param target entity
  --- @return nil
  register_aggression = function(self, source, target)
    table.insert(self._next_aggression_log, {source, target})
  end,

  --- @param self state
  --- @param source entity
  --- @param target entity
  --- @return boolean
  check_aggression = function(self, source, target)
    return Fun.iter(self._aggression_log)
      :any(function(pair) return pair[1] == source and pair[2] == target end)
  end,
}

module_mt.__call = function(_, systems)
	local result = Table.extend(state_base, {
    _dependencies = {},
    _aggression_log = {},
    _next_aggression_log = {},
    _world = Tiny.world(unpack(systems)),
    _entities = {},
	})

  local modes = {
    "creator", "death", "reading", "dialogue_options", "dialogue", "free", "combat",
    "text_input",
  }

  result.gui = require("state.gui")()
  result.hotkeys = require("state.hotkeys")(modes)
  result.ambient = require("state.ambient")()
  result.mode = require("state.mode")(result.gui.views_order)

  return result
end

return state
