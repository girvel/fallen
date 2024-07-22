local tablex = require("lib.tablex")


describe("Table extension module", function()
  describe("extend", function()
    it("uses pairs to copy data", function()
      local t = {a = 1}
      tablex.extend(t, {b = 2, c = 3})
      assert.same({a = 1, b = 2, c = 3}, t)
    end)
  end)

  describe("concat", function()
    it("uses ipairs to copy data", function()
      local t = {1}
      tablex.concat(t, {2, 3})
      assert.same({1, 2, 3}, t)
    end)
  end)

  describe("join", function()
    it("uses both pairs and ipairs to copy data", function()
      local t = {1, a = 1}
      tablex.join(t, {2, 3, b = 2, c = 3})
      assert.same({1, 2, 3, a = 1, b = 2, c = 3}, t)
    end)
  end)

  describe("shallow_same", function()
    it("comapares two tables structurally on the 1st level of recursion", function()
      assert.is_true(tablex.shallow_same({}, {}))
      assert.is_true(tablex.shallow_same({a = 1}, {a = 1}))
      assert.is_false(tablex.shallow_same({a = 1}, {a = 1, b = 1}))
    end)
  end)
end)
