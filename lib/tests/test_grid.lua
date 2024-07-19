local grid = require("lib.grid")
local vector = require("lib.vector")


describe("Grid library", function()
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
      local grid = grid.from_matrix({
        {0, 0, 0},
        {0, 1, 0},
        {0, 0, 0},
      }, vector({3, 3}))

      assert.are_same(
        {vector({1, 1}), vector({2, 1}), vector({3, 1})},
        grid:find_path(vector({1, 2}), vector({3, 1}))
      )
    end)
  end)
end)
