describe("Vector library", function()
  _G.unpack = table.unpack
  _G.Fun = require("vendor.fun")

  local vector = require("lib.vector")

  describe("Vector.use", function()
    it("Uses function separately on xs and ys and builds vector from the result", function()
      assert.equal(
        vector({2, 3}),
        vector.use(math.max, vector({1, 2}), vector({2, -3}), vector({0, 3}))
      )
    end)
  end)
end)
