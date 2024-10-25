describe("Query monad", function()
  local query = require("lib.essential.query")

  it("can perform nil-conditional indexing", function()
    local t = {
      first = {a = {b = {c = 3}}},
      second = {a = {}},
      third = {a = "a3"},
    }

    assert.equal(3, -query(t.first).a.b.c)
    assert.equal(nil, -query(t.second).a.b.c)
    assert.equal(nil, -query(t.third).a.b.c)
  end)

  it("can perform nil-conditional assignment", function()
    local t = {
      first = {a = {b = {c = 3}}},
      second = {},
      third = "3a",
    }

    query(t.first).a = 4
    query(t.second).a = 4
    query(t.third).a = 4

    assert.same({
      first = {a = 4},
      second = {a = 4},
      third = "3a",
    }, t)
  end)

  it("can perform nil-conditional call", function()
    local t = {
      first = function() return 3 end,
      second = nil,
      third = "a3",
    }

    assert.equal(3, -query(t.first)())
    assert.equal(nil, -query(t.second)())
    assert.equal(nil, -query(t.third)())
  end)

  it("can perform nil-conditional self-call", function()
    local t = {
      value = 3,
      f = function(self) return self.value end,
    }

    assert.equal(3, -query(t):f())
  end)
end)
