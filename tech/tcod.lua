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


local snapshot_methods = {}

if tcod_c then
  tcod.snapshot = function()
    local w, h = unpack(State.grids.solids.size)
    local map = tcod_c.TCOD_map_new(w, h)
    for x = 1, w do
      for y = 1, h do
        local e = State.grids.solids:fast_get(x, y)
        tcod_c.TCOD_map_set_properties(
          map, x - 1, y - 1, Common.bool(not e or e.transparent_flag), not e
        )
      end
    end

    return setmetatable({_map = map}, {__index = snapshot_methods})
  end

  snapshot_methods.refresh_fov = function(self)
    local px, py = unpack(State.player.position - Vector.one)
    tcod_c.TCOD_map_compute_fov(
      self._map, px, py, State.player.fov_radius, true, tcod_c.FOV_PERMISSIVE_8
    )
  end

  snapshot_methods.is_visible = function(self, position)
    assert(State.grids.solids:can_fit(position))
    return tcod_c.TCOD_map_is_in_fov(self._map, position[1] - 1, position[2] - 1)
  end

  snapshot_methods.is_transparent = function(self, position)
    assert(State.grids.solids:can_fit(position))
    return tcod_c.TCOD_map_is_transparent(self._map, position[1] - 1, position[2] - 1)
  end

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

  tcod.snapshot = function()
    return setmetatable({
      r = nil,
      player_position = nil,
    }, {__index = snapshot_methods})
  end

  snapshot_methods.refresh_fov = function(self)
    self.r = State.player.fov_radius
    self.player_position = State.player.position
  end

  snapshot_methods.is_visible = function(self, position)
    assert(State.grids.solids:can_fit(position))
    assert(self.r and self.player_position)
    return (position - self.player_position):abs() <= self.r
  end

  snapshot_methods.is_transparent = function(self, position)
    assert(State.grids.solids:can_fit(position))
    local e = State.grids.solids:fast_get(unpack(position))
    return Common.bool(not e or e.transparent_flag)
  end

  snapshot_methods.find_path = function(self, origin, destination)
    return {}
  end
end

return tcod
