local static = require("library.static")
local mobs = require("library.mobs")
local weapons = require("library.weapons")


return Module("library.palette", {
  factories = {
    -- tiles -- 
    _ = static.planks,
    [","] = static.walkway,
    ["-"] = static.steel_floor,

    -- solids --
    ["#"] = static.wall,
    ["%"] = static.crooked_wall,
    S = static.smooth_wall,
    W = static.steel_wall,
    V = static.steel_wall_variant,
    M = static.steel_wall_mirror,

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

    p = static.device_panel,
    P = static.device_panel_broken,
    f = static.furnace,
    t = static.table,
    k = static.locker,
    K = static.locker_damaged,
    c = static.cabinet,
    C = static.cabinet_damaged,
    a = static.crate,
    ["$"] = static.chest,
    h = static.chamber_pot,
    u = static.bucket,
    s = static.sink,

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
    t = function(grid, position)
      local left = grid:safe_get(position + Vector.left)
      local right = grid:safe_get(position + Vector.right)
      local up = grid:safe_get(position + Vector.up)
      local down = grid:safe_get(position + Vector.down)

      if left == "t" then
        if right == "t" then
          return static.table_hor
        end
        return static.table_right
      end

      if right == "t" then
        return static.table_left
      end
    end,
    b = function (grid, position)
      if grid:safe_get(position + Vector.up) == "b" then
        return static.lower_bed
      end

      if grid:safe_get(position + Vector.down) == "b" then
        return static.upper_bed
      end

      return static.bed
    end,
    ["."] = function(grid, position)
      if math.random() <= 0.3 then
        return static.walkway
      end
      return static.planks
    end
  },
  transparents = Common.set("Dl@gdr>v<^\\/FB}{T+o01234LpPtkKba$husQ"),
  throwables = Common.set("_,-."),
})
