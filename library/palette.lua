local engine = require("library.engine")
local things = require("library.things")
local live = require("library.live")
local mobs = require("library.mobs")
local items = require("library.items")
local decorations = require("library.decorations")
local walls = require("library.walls")
local pipes = require("library.pipes")
local tiles = require("library.tiles")
local player = require("state.player")


local pipes_characters = Common.set(">v<^\\/FB}{T+oLp")
local walls_set = Common.set("WM")
local countertop_set = Common.set("rU")

return Module("library.palette", {
  transparents = Common.set([[D@gr>v<^\/FB}{T+o01234LpPtkKba$HuUOSsQhbs|dmRAl]] .. engine.char),
  throwables = Common.set([[-.']]),
  factories = {
    ["@"] = player,

    -- tiles -- 
    ["'"] = tiles.steel_floor_dirty,

    -- things --
    l = things.toilet,

    -- solids --
    M = walls.steel_with_mirror,
    E = walls.steel_vented,

    [">"] = pipes.horizontal,
    v = pipes.vertical,
    ["<"] = pipes.horizontal_braced,
    ["^"] = pipes.vertical_braced,
    ["\\"] = pipes.left_back,
    ["/"] = pipes.forward_left,
    F = pipes.right_forward,
    B = pipes.back_right,
    ["}"] = pipes.left_down,
    ["{"] = pipes.right_down,
    T = pipes.T_up,
    ["+"] = pipes.x,
    o = pipes.valve,
    L = pipes.leaking_left_down,

    n = decorations.device_panel,
    N = decorations.device_panel_broken,
    f = decorations.furnace,
    t = decorations.table,
    k = decorations.locker,
    K = decorations.locker_damaged,
    c = decorations.cabinet,
    C = decorations.cabinet_damaged,
    a = decorations.crate,
    ["$"] = decorations.chest,
    H = decorations.chamber_pot,
    u = decorations.bucket,
    U = decorations.cauldron,
    O = decorations.oven,
    S = decorations.kitchen_sink,
    h = decorations.stool,
    A = decorations.sofa,
    b = decorations.bed,
    s = decorations.sink,
    w = decorations.steel_wall_window,
    q = decorations.steel_wall_transparent,
    g = decorations.cage,

    Q = live.mannequin,
    R = live.lever,

    ["0"] = mobs.old_dreamer,
    ["1"] = mobs[1],
    ["2"] = mobs[2],
    ["3"] = mobs[3],
    ["4"] = mobs[4],

    -- items -- 
    ["|"] = items.pole,
    d = items.dagger,
    m = items.machete,
  },
  complex_factories = {
    [engine.char] = engine.complex_factory,

    W = function(grid, position)
      if grid:safe_get(position + Vector.down) == "U" then
        return walls.steel_behind_cauldron
      end
      if math.random() <= 0.5
        and Fun.iter(Vector.directions)
          :any(function(d) return grid:safe_get(position + d) == "~" end)
      then
        return walls.steel_vined
      end
      if math.random() <= 0.3 then
        return walls.steel_variant
      end
      return walls.steel
    end,

    V = function(grid, position)
      if math.random() <= .4 then
        return walls.steel_dirty
      end
      return walls.steel
    end,

    t = function(grid, position)
      local left = grid:safe_get(position + Vector.left)
      local right = grid:safe_get(position + Vector.right)
      local up = grid:safe_get(position + Vector.up)
      local down = grid:safe_get(position + Vector.down)

      if left == "t" then
        if right == "t" then
          return decorations.table_hor
        end
        return decorations.table_right
      end

      if right == "t" then
        return decorations.table_left
      end

      if up == "t" then
        if down == "t" then
          return decorations.table_ver
        end
        return decorations.table_down
      end

      if down == "t" then
        return decorations.table_up
      end
    end,

    b = function (grid, position)
      if grid:safe_get(position + Vector.up) == "b" then
        return decorations.lower_bed
      end

      if grid:safe_get(position + Vector.down) == "b" then
        return decorations.upper_bed
      end
    end,

    ["."] = function(grid, position)
      if math.random() <= 0.3 then
        return tiles.walkway
      end
      return tiles.planks
    end,

    ["-"] = function(grid, position)
      if math.random() <= 0.1 then
        return tiles.steel_damaged
      end
      return tiles.steel_floor
    end,

    ["_"] = function(grid, position)
      if math.random() <= 0.1 then
        return tiles.steel_barred_damaged
      end
      return tiles.steel_barred
    end,

    p = function(grid, position)
      local vertical = math.random() < 0.3 and pipes.vertical_braced or pipes.vertical
      local horizontal = math.random() < 0.3 and pipes.horizontal_braced or pipes.horizontal

      local i = Fun.iter(Vector.direction_names)
        :enumerate()
        :map(function(i, name)
          return pipes_characters[grid:safe_get(position + Vector[name])]
            and 2 ^ (i - 1)
            or 0
        end)
        :sum()

      return ({
        nil, vertical, horizontal, pipes.forward_left,
        vertical, vertical, pipes.left_back, pipes.T_right,
        horizontal, pipes.right_forward, horizontal, pipes.T_down,
        pipes.back_right, pipes.T_left, pipes.T_up, pipes.x
      })[i + 1]
    end,

    r = function(grid, position)
      local n = Fun.iter(Vector.direction_names)
        :map(function(name) return name, grid:safe_get(position + Vector[name]) end)
        :tomap()

      if countertop_set[n.left] then
        if countertop_set[n.down] then
          return decorations.countertop_left_down
        end
      end

      if countertop_set[n.right] then
        if countertop_set[n.down] then
          return decorations.countertop_right_down
        end
      end

      if countertop_set[n.up] then
        if walls_set[n.left] then
          if countertop_set[n.down] then
            return decorations.countertop_left
          end
          return decorations.countertop_left_corner_down
        end
        if countertop_set[n.down] then
          return decorations.countertop_right
        end
        return decorations.countertop_right_corner_down
      end

      if countertop_set[n.down] then
        if walls_set[n.left] then
          return decorations.countertop_left_corner_up
        end
        return decorations.countertop_right_corner_up
      end

      return decorations.countertop
    end,

    D = function(grid, position)
      if grid:safe_get(position + Vector.right) == "D" then
        if grid:safe_get(position + Vector.left) == "D" then
          return walls.megadoor_middle
        end
        return walls.megadoor_left
      end
      if grid:safe_get(position + Vector.left) == "D" then
        return walls.megadoor_right
      end
      return live.door
    end
  },
})
