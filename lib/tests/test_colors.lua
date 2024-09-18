describe("Colors", function()
  _G.unpack = table.unpack
  _G.Module = require("lib.types.module")
  _G.Pairs = require("lib.essential.pairs")
  _G.Table = require("lib.essential.table")
  local colors = require("lib.colors")

  describe(".equal(a, b)", function()
    it("checks equality of two colors", function()
      assert.is_true(colors.equal({1, 1, 0}, {1, 1, 0}))
      assert.is_false(colors.equal({1, 1, 0}, {1, 1, 1}))
      assert.is_true(colors.equal({1, 0.5, 0}, {1, 0.5, 0}))
    end)

    it("handles #=3 and #=4", function()
      assert.is_true(colors.equal({1, 1, 0, 1}, {1, 1, 0}))
    end)

    it("handles float equality precision", function()
      assert.is_true(colors.equal({1, 0, 0}, {0.999, 0, 0}))
    end)
  end)
end)
