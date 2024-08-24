describe("Sorted map", function()
  _G.unpack = unpack or table.unpack
  _G.Fun = require("lib.fun")
  local sorted_map = require("lib.sorted_map")
  it("works", function()
    local t = sorted_map({a = 1})
    t.b = 2
    assert.equal(t.a, 1)
    assert.equal(t.b, 2)
    assert.same(Fun.iter(t):map(function(...) return {...} end):totable(), {{"a", 1}, {"b", 2}})
  end)
end)
