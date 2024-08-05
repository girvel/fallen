local interactive = require("tech.interactive")
local animated = require("tech.animated")
local level = require("tech.level")
local static_sprite = require("tech.static_sprite")
local atlas_sprite = require("tech.atlas_sprite")
local library_fx = require("library.fx")
local random = require("utils.random")


local module = {}

-- atlases --
local pipe_atlas = "assets/atlases/pipes.png"

for i, name in ipairs({
  "pipe_horizontal", "pipe_vertical", "pipe_horizontal_braced", "pipe_vertical_braced",
  "pipe_left_back", "pipe_forward_left", "pipe_right_forward", "pipe_back_right",
  "pipe_left_down", "pipe_forward_down", "pipe_right_down", "pipe_back_down",
  "pipe_T", "pipe_x",
}) do
  module[name] = function()
    return Tablex.extend(
      atlas_sprite(pipe_atlas, i),
      {
        layer = "solids",
        view = "scene",
        codename = name,
        transparent_flag = true,
      }
    )
  end
end

local decorations_atlas = "assets/sprites/decorations_atlas.png"

Fun.iter({
  false, "device_panel_broken", "furnace", "table", "locker", "locker_damaged", "cabinet", "cabinet_damaged",
  "bed", "crate", "crate_open", "chest", "chest_open", "table_left", "table_hor", "table_right",
}):enumerate():each(function(i, name)
  if not name then return end
  module[name] = function()
    return Tablex.extend(
      atlas_sprite(decorations_atlas, i),
      {
        view = "scene",
        layer = "solids",
        codename = name,
        transparent_flag = true,
      }
    )
  end
end)

local steel_sounds = {
}

for i, name in ipairs({
  "steel_floor",
}) do
  if not name then return end
  module[name] = function()
    return Tablex.extend(
      atlas_sprite("assets/sprites/tile_atlas.png", i),
      {
        view = "scene",
        layer = "tiles",
        codename = name,
        sounds = steel_sounds,
      }
    )
  end
end

-- atlas extensions --
local valve_rotating_sounds = Common.volumed_sounds("assets/sounds/valve_rotate", 0.1)
local pipe_valve_pack = animated.load_pack("assets/sprites/pipe_valve")

module.pipe_valve = function(leaking_pipe_position)
  return Tablex.extend(
    animated(pipe_valve_pack),
    interactive(function(self, other)
      local target = State.grids.solids[leaking_pipe_position]
      self:animate("rotate")
      State.audio:play(self, random.choice(valve_rotating_sounds), "medium")
      self:when_animation_ends(function()
        target.overflow_counter = 0
        target:burst_with_steam()
      end)
    end, true),
    {
      layer = "solids",
      view = "scene",
      name = "Вентиль",
      codename = "pipe_valve",
      transparent_flag = true,
    }
  )
end

local steam_hissing_sound = Common.volumed_sounds("assets/sounds/steam_hissing.wav", 0.8)[1]

module.leaking_pipe_left_down = function()
  local sound = Common.volumed_sounds("assets/sounds/steam_hissing_loop.wav", 1)[1]
  sound:setLooping(true)

  return Tablex.extend(
    atlas_sprite(pipe_atlas, 9),
    {
      layer = "solids",
      view = "scene",
      transparent_flag = true,

      codename = "leaking_pipe_left_down",
      trigger_seconds = 5,
      overflow_counter = 0,
      sound_loop = sound,
      paused = false,

      ai = {run = function(self, event)
        local dt = unpack(event)
        self.overflow_counter = self.overflow_counter + dt

        if self.overflow_counter >= 60 then
          State.audio:play(self, self.sound_loop)
          if Common.relative_period(1, dt, self, "steam") then
            self:burst_with_steam()
          end
          return
        end
        self.sound_loop:stop()

        if Common.relative_period(self.trigger_seconds, dt, self, "steam") then
          self.trigger_seconds = 8 + math.random() * 4
          self:burst_with_steam()
        end
      end},

      burst_with_steam = function(self)
        if self.paused then return end

        State:add(Tablex.extend(
          library_fx.steam("right"),
          {position = self.position}
        ))
        State.audio:play(self, steam_hissing_sound:clone())
      end,
    }
  )
end

module.device_panel = function()
  return Tablex.extend(
    atlas_sprite(decorations_atlas, 1),
    {
      view = "scene",
      layer = "solids",
      codename = "device_panel",
      hp = 1,
      hardness = 15,
      sounds = {
        hit = Common.volumed_sounds("assets/sounds/glass_breaking", 0.5),
      },
      on_remove = function(self)
        State:add(Tablex.extend(module.device_panel_broken(), {position = self.position}))
      end,
      transparent_flag = true,
    }
  )
end

-- plain sprites --
-- TODO refactor?
local lever_packs = {
  on = animated.load_pack("assets/sprites/lever_on"),
  off = animated.load_pack("assets/sprites/lever_off"),
}

module.lever = function()
  return Tablex.extend(
    animated(lever_packs.off),
    interactive(function(self)
      self.is_on = self.animation.pack ~= lever_packs.on
      local next_state = self.is_on and "on" or "off"
      self:animate("turn_" .. next_state)
      self:when_animation_ends(function(self)
        self.animation.pack = lever_packs[next_state]
      end)
    end),
    {name = "рычаг", is_on = false,}
  )
end

local closed_door_pack = animated.load_pack("assets/sprites/closed_door")
local open_door_pack = animated.load_pack("assets/sprites/open_door")

module.door = function(args)
  args = args or {}
  return Tablex.extend(
    animated(closed_door_pack),
    args.locked and {} or interactive(function(self)
      self:open()
      self.interact = nil
    end, not args.highlighted),
    {
      layer = "solids",
      view = "scene",
      name = "дверь",
      is_open = false,
      open = function(self)
        self:animate("open")
        self:when_animation_ends(function(_)
          self.animation.pack = open_door_pack
          level.change_layer(State.grids, self, "above_solids")
          self.is_open = true
        end)
      end,
    }
  )
end

module.scripture = function(kind, path)
  assert(kind)
  return Tablex.extend(
    path and interactive(function(self)
      State.gui.wiki:show(self.path)
    end) or {},
    static_sprite("assets/sprites/scripture_" .. (kind or "straight") .. ".png"),
    {
      layer = "tiles",
      view = "scene",
      name = "древняя надпись",
      path = path
    }
  )
end

local mannequin_sounds = {
  hit = Common.volumed_sounds("assets/sounds/hits_body", 0.3),
}

module.mannequin = function()
  return Tablex.extend(
    static_sprite("assets/sprites/mannequin.png"),
    {
      layer = "solids",
      view = "scene",
      name = "манекен",
      hp = 1000,
      get_armor = function() return 5 end,
      sounds = mannequin_sounds,
    }
  )
end

local planks_sounds = {
  move = Common.volumed_sounds("assets/sounds/move_planks", 0.1)
}

module.planks = function()
  return Tablex.extend(
    static_sprite("assets/sprites/planks.png"),
    {
      layer = "tiles",
      view = "scene",
      codename = "planks",
      sounds = planks_sounds,
    }
  )
end

local walkway_sounds = {
  move = Common.volumed_sounds("assets/sounds/move_walkway", 0.1),
}

module.walkway = function()
  return Tablex.extend(
    static_sprite("assets/sprites/walkway.png"),
    {
      layer = "tiles",
      view = "scene",
      codename = "walkway",
      sounds = walkway_sounds,
    }
  )
end

for _, name in ipairs({
  "wall", "bushes", "smooth_wall", "crooked_wall", "sand", "wall_with_vines",
  "key_point", "steel_wall", "steel_wall_variant",
}) do
  module[name] = function()
    return Tablex.extend(
      static_sprite("assets/sprites/" .. name .. ".png"),
      {
        layer = "solids",
        view = "scene",
        codename = name,
      }
    )
  end
end

return module
