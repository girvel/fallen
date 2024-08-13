local level = require("state.level")
local combat = require("tech.combat")
local mech = require("mech")
local sprite = require("tech.sprite")


local module, module_mt, static = Module("state")

module_mt.__call = function(_, systems, debug_mode)
  local modes = {
    "character_creator", "death", "reading", "dialogue_options", "dialogue", "free", "combat", "text_input",
  }

	return {
    -- grids
    -- rails
    world = Tiny.world(unpack(systems)),
    grids = nil,

    debug_mode = debug_mode,

    SCALING_FACTOR = 4,
    MODES = modes,

    gui = require("state.gui")(),
    hotkeys = require("state.hotkeys")(modes, debug_mode),
    audio = require("state.audio")(),

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
      Tablex.extend(entity, ...)
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
        Log.debug("State:remove(%s)" % Common.get_name(entity))
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
        :map(function(layer)
          return layer, Grid(
            level_size,
            level.GRID_COMPLEX_LAYERS[layer]
              and function() return {} end
              or nil
          )
        end)
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
      self.background_dummy = State:add({
        sprite = sprite.image("assets/sprites/water_sketch_02.png"),
      })
    end,

    get_mode = function(self)
      if self.gui.text_input.active then
        return "text_input"
      elseif self.gui.character_creator.text_entities then
        return "character_creator"
      elseif self.player.hp <= 0 then
        return "death"
      elseif self.gui.wiki.text_entities then
        return "reading"
      elseif self.gui.dialogue.options then
        return "dialogue_options"
      elseif self.gui.dialogue._entities then
        return "dialogue"
      elseif self.combat then
        return "combat"
      else
        return "free"
      end
    end,

    start_combat = function(self, list)
      local current_i = 1
      if State.combat then
        list = Fun.iter(list)
          :filter(function(e) return not Tablex.contains(State.combat.list, e) end)
          :totable()
          current_i = State.combat.current_i
      end

      Fun.iter(list):each(function(e)
        e.current_initiative = (D(20) + mech.get_modifier(e.abilities.dex)):roll()
      end)

      Tablex.concat(list, -Query(State.combat):iter_entities_only():totable())
      table.sort(list, function(a, b) return a.current_initiative < b.current_initiative end)

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
end

return module
