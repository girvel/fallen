local ffi = require("ffi")

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
]])

for _, path in ipairs({
  "lib/libtcod",
  love.filesystem.getSource() .. "/lib/libtcod",
  love.filesystem.getSourceBaseDirectory() .. "/libtcod",
}) do
  local ok, result = pcall(ffi.load, path)
  if ok then return result end
end

Log.error("Unable to locate libtcod library")
