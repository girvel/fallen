describe("Grid library", function()
  _G.unpack = table.unpack
  _G.Table = require("lib.table")
  _G.Fun = require("vendor.fun")
  _G.Vector = require("lib.vector")
  _G.Module = require("lib.module")
  require("lib.string")

  local grid = require("lib.grid")
  local vector = require("lib.vector")


  describe("grid.from_matrix()", function()
    it("should build a grid from matrix", function()
      local base_matrix = {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9},
      }
      assert.are_same(
        {1, 2, 3, 4, 5, 6, 7, 8, 9},
        grid.from_matrix(base_matrix, vector({3, 3}))._inner_array
      )
    end)
  end)

  describe("find_path", function()
    it("should find paths", function()
      local this_grid = grid.from_matrix({
        {nil, nil, nil},
        {nil, 1,   nil},
        {nil, nil, nil},
      }, vector({3, 3}))

      assert.are_same(
        {vector({1, 1}), vector({2, 1}), vector({3, 1})},
        this_grid:find_path(vector({1, 2}), vector({3, 1}))
      )
    end)

    it("should work with start & end occupied", function()
      local this_grid = grid.from_matrix({
        {nil, nil, 1  },
        {1,   1,   nil},
        {nil, nil, nil},
      }, vector({3, 3}))

      assert.are_same(
        {vector({1, 1}), vector({2, 1}), vector({3, 1})},
        this_grid:find_path(vector({1, 2}), vector({3, 1}))
      )
    end)

    it("should find the next best thing if there is no full path", function()
      local this_grid = grid.from_matrix({
        {1,   1,   1  },
        {1,   1,   1  },
        {nil, nil, nil},
      }, vector({3, 3}))

      assert.are_same(
        {vector({2, 3}), vector({3, 3})},
        this_grid:find_path(vector({1, 3}), vector({3, 1}))
      )
    end)

    it("should work with distance limit", function()
      local this_grid = grid.from_matrix({
        {nil, nil, nil, nil, nil},
      }, vector({5, 1}))
      local max_distance = 3
      local path = this_grid:find_path(vector({1, 1}), vector({5, 1}), max_distance)
      assert.is_true(#path >= max_distance)
      assert.is_true(#path < this_grid.size[1])
    end)
  end)

  describe("find_free_position", function()
    it("finds the closest nil", function()
      local this_grid = grid.from_matrix({
        {nil, nil, 111},
        {111, 111, 111},
        {111, 111, 111},
      }, vector({3, 3}))

      assert.equal(vector({2, 1}), this_grid:find_free_position(vector({2, 2})))
    end)

    it("does not clash with grid borders", function()
      local this_grid = grid.from_matrix({
        {nil, nil, 111},
        {111, 111, 111},
        {111, 111, 111},
      }, vector({3, 3}))

      assert.equal(vector({2, 1}), this_grid:find_free_position(vector({3, 3})))
    end)

    it("can accept max radius value", function()
      local this_grid = grid.from_matrix({
        {nil, nil, 111},
        {111, 111, 111},
        {111, 111, 111},
      }, vector({3, 3}))

      assert.equal(nil, this_grid:find_free_position(vector {3, 3}, 2))
    end)
  end)
end)
