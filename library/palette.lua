local static = require("library.static")
local mobs = require("library.mobs")
local weapons = require("library.weapons")
local decorations = require("library.decorations")
local walls = require("library.walls")


return Module("library.palette", {
  factories = {
    -- tiles -- 
    _ = static.planks,
    [","] = static.walkway,
    ["-"] = static.steel_floor,

    -- solids --
    M = walls.steel_with_mirror,

    [">"] = static.pipe_horizontal,
    v = static.pipe_vertical,
    ["<"] = static.pipe_horizontal_braced,
    ["^"] = static.pipe_vertical_braced,
    ["\\"] = static.pipe_left_back,
    ["/"] = static.pipe_forward_left,
    F = static.pipe_right_forward,
    B = static.pipe_back_right,
    ["}"] = static.pipe_left_down,
    ["{"] = static.pipe_right_down,
    T = static.pipe_T,
    ["+"] = static.pipe_x,
    o = static.pipe_valve,
    L = static.leaking_pipe_left_down,

    p = decorations.device_panel,
    P = decorations.device_panel_broken,
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
        return static.walkway
      end
      return static.planks
    end,
  },
  transparents = Common.set("Dl@gdr>v<^\\/FB}{T+o01234LpPtkKba$husQ"),
  throwables = Common.set("_,-."),
})
