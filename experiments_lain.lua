local ffi = require("ffi")
local serpent = require("lib.serpent")


local experiments = {}

experiments.tcod = function()
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
  local libtcod = ffi.load("lib/libtcod")

  local map = libtcod.TCOD_map_new(3, 3)
  libtcod.TCOD_map_set_properties(map, 1, 1, false, true)
  Log.info(libtcod.TCOD_map_is_transparent(map, 1, 1))
  Log.info(libtcod.TCOD_map_is_walkable(map, 1, 1))
  libtcod.TCOD_map_compute_fov(map, 0, 0, 3, true, ffi.C.FOV_BASIC)
  Log.info(libtcod.TCOD_map_is_in_fov(map, 1, 1))
  Log.info(libtcod.TCOD_map_is_in_fov(map, 2, 2))
end

experiments.serialization = function()
  -- test function serialization
  local f = function(x)
    Log.trace(x)
  end
  loadstring(serpent.dump(f))()("Serialization works!")

  -- test LOVE2D data serialization
  local image = love.graphics.newImage("assets/sprites/bushes.png")
  -- Log.trace(loadstring(serpent.dump(image))():getDimensions())
  -- DOES NOT WORK

  -- test dump size
  local state_dump = serpent.dump(State)
  Log.trace("Serialized state is %.2f KB" % (#state_dump / 1024))
end

return experiments
