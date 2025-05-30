local ffi = require("ffi")


local tcod, module_mt, static = Module("tech.tcod")

ffi.cdef([[
  typedef enum {
    FOV_BASIC, 
    FOV_DIAMOND, 
    FOV_SHADOW, 
    FOV_PERMISSIVE_0,FOV_PERMISSIVE_1,FOV_PERMISSIVE_2,FOV_PERMISSIVE_3,
    FOV_PERMISSIVE_4,FOV_PERMISSIVE_5,FOV_PERMISSIVE_6,FOV_PERMISSIVE_7,FOV_PERMISSIVE_8, 
    FOV_RESTRICTIVE,
    NB_FOV_ALGORITHMS
  } TCOD_fov_algorithm_t;

  struct TCOD_Map *TCOD_map_new(int width, int height);
  void TCOD_map_clear(struct TCOD_Map *map, bool transparent, bool walkable);

  void TCOD_map_set_properties(
    struct TCOD_Map *map, int x, int y, bool is_transparent, bool is_walkable
  );

  void TCOD_map_compute_fov(
    struct TCOD_Map *map, int player_x, int player_y, int max_radius, bool light_walls,
    TCOD_fov_algorithm_t algo
  );

  bool TCOD_map_is_transparent(struct TCOD_Map *map, int x, int y);
  bool TCOD_map_is_walkable(struct TCOD_Map *map, int x, int y);
  bool TCOD_map_is_in_fov(struct TCOD_Map *map, int x, int y);

  // struct TCOD_Dijkstra *TCOD_dijkstra_new(struct TCOD_Map *map, float diagonalCost);
  // void TCOD_dijkstra_delete(TCOD_Dijkstra *dijkstra);

  struct TCOD_Path *TCOD_path_new_using_map(struct TCOD_Map *map, float diagonalCost);
  void TCOD_path_delete(struct TCOD_Path *path);

  bool TCOD_path_compute(struct TCOD_Path *path, int ox, int oy, int dx, int dy);
  int TCOD_path_size(struct TCOD_Path *path);
  void TCOD_path_get(struct TCOD_Path *path, int index, int *x, int *y);
]])

local tcod_c = Common.load_c_library("libtcod")


--- @class snapshot
--- @field _map any
--- @field r integer
--- @field px integer
--- @field py integer
local snapshot_methods = {}

if tcod_c then
  --- To be called on empty grid
  tcod.observer = function(grid)
    local w, h = unpack(grid.size)
    local map = tcod_c.TCOD_map_new(w, h)
    for x = 1, w do
      for y = 1, h do
        local e = grid:fast_get(x, y)
        tcod_c.TCOD_map_set_properties(
          map, x - 1, y - 1, Common.bool(not e or e.transparent_flag), not e
        )
      end
    end
    local snapshot = setmetatable({_map = map}, {__index = snapshot_methods})
    return setmetatable({
      _tcod__snapshot = snapshot,
      _tcod__grid = grid,
    }, {
      __index = grid,

      __newindex = function(self, index, value)
        grid[index] = value
        local x, y = unpack(index)
        tcod_c.TCOD_map_set_properties(
          rawget(self, "_tcod__snapshot")._map,
          x - 1, y - 1,
          Common.bool(not value or value.transparent_flag), not value
        )
      end,

      __serialize = function(self)
        local grid_copy = self._tcod__grid
        return function()
          return tcod.observer(grid_copy)
        end
      end,
    })
  end

  --- @return snapshot
  tcod.snapshot = function()
    do return rawget(State.grids.solids, "_tcod__snapshot") end
  end

  --- @return nil
  snapshot_methods.refresh_fov = function(self)
    local px, py = unpack(State.player.position - Vector.one)
    tcod_c.TCOD_map_compute_fov(
      self._map, px, py, State.player.fov_radius, true, tcod_c.FOV_PERMISSIVE_8
    )
  end

  --- @param x integer
  --- @param y integer
  --- @return boolean
  snapshot_methods.is_visible_unsafe = function(self, x, y)
    return tcod_c.TCOD_map_is_in_fov(self._map, x - 1, y - 1)
  end

  --- @param x integer
  --- @param y integer
  --- @return boolean
  snapshot_methods.is_transparent_unsafe = function(self, x, y)
    return tcod_c.TCOD_map_is_transparent(self._map, x - 1, y - 1)
  end

  --- @param origin vector
  --- @param destination vector
  --- @return vector[]
  snapshot_methods.find_path = function(self, origin, destination)
    assert(State.grids.solids:can_fit(origin))
    assert(State.grids.solids:can_fit(destination))

    local raw_path = tcod_c.TCOD_path_new_using_map(self._map, 0)
    local ox, oy = unpack(origin - Vector.one)
    local dx, dy = unpack(destination - Vector.one)
    tcod_c.TCOD_path_compute(raw_path, ox, oy, dx, dy)

    local result = {}
    for i = 0, tcod_c.TCOD_path_size(raw_path) - 1 do
      local xp = ffi.new("int[1]")
      local yp = ffi.new("int[1]")
      tcod_c.TCOD_path_get(raw_path, i, xp, yp)
      table.insert(result, Vector {xp[0], yp[0]} + Vector.one)
    end
    tcod_c.TCOD_path_delete(raw_path)

    return result
  end

else
  Log.error("Unable to locate libtcod library")

  tcod.observer = function(grid)
    return grid
  end

  tcod.snapshot = function()
    return setmetatable({}, {__index = snapshot_methods})
  end

  snapshot_methods.refresh_fov = function(self)
    self.r = math.floor(State.player.fov_radius * 2 / 3)
    self.px, self.py = unpack(State.player.position)
  end

  snapshot_methods.is_visible_unsafe = function(self, x, y)
    return math.abs(self.px - x) <= self.r and math.abs(self.py - y) <= self.r
  end

  snapshot_methods.is_transparent_unsafe = function(self, x, y)
    local e = State.grids.solids:fast_get(x, y)
    return Common.bool(not e or e.transparent_flag)
  end

  snapshot_methods.find_path = function(self, origin, destination)
    return {}
  end
end

return tcod
