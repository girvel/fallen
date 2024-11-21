describe("Ordered map", function()
  _G.unpack = unpack or table.unpack
  _G.Fun = require("vendor.fun")


  local ordered_map = require("lib.ordered_map")

  it("works", function()
    local t = ordered_map({a = 1})
    t.b = 2
    assert.equal(t.a, 1)
    assert.equal(t.b, 2)
    assert.same({{"a", 1}, {"b", 2}}, ordered_map.iter(t):map(function(...) return {...} end):totable())
  end)

  it("can be iterated over", function()
    local base = {a = 1, b = 2}
    local i = 0
    for k, v in ordered_map.pairs(ordered_map(base)) do
      i = i + 1
      assert.equal(base[k], v)
    end
    assert.equal(2, i)
  end)

  it("does not have key collision", function()
    assert.equal(ordered_map({base = 1}).base, 1)
  end)
end)
