local static = require("library.static")
local mobs = require("library.mobs")
local weapons = require("library.weapons")
local decorations = require("library.decorations")
local walls = require("library.walls")
local pipes = require("library.pipes")
local tiles = require("library.tiles")


local pipes_characters = Common.set(">v<^\\/FB}{T+oLp")

return Module("library.palette", {
  factories = {
    -- tiles -- 
    _ = tiles.planks,
    [","] = tiles.walkway,
    ["-"] = tiles.steel_floor,

    -- solids --
    M = walls.steel_with_mirror,

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
    h = decorations.chamber_pot,
    u = decorations.bucket,
    s = decorations.sink,
    b = decorations.bed,

    Q = static.mannequin,
    D = static.door,
    l = static.lever,

    ["0"] = mobs.dreamer,
    ["1"] = mobs[1],
    ["2"] = mobs[2],
    ["3"] = mobs[3],
    ["4"] = mobs[4],

    -- items -- 
    g = weapons.greatsword,
    d = weapons.dagger,
    r = weapons.rapier,
  },
  complex_factories = {
    ["W"] = function(grid, position)
      if math.random() <= 0.3 then
        return walls.steel_variant
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
    end
  },
  transparents = Common.set("Dl@gdr>v<^\\/FB}{T+o01234LpPtkKba$husQ"),
  throwables = Common.set("_,-."),
})
