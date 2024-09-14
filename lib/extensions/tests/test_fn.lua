describe("lib.extensions.fn", function()
  _G.unpack = table.unpack
  local fn = require("lib.extensions.fn")

  describe("__call(_, ...)", function()
    it("creates a static function", function()
      local f = fn(3, 4, 5)
      assert.same({3, 4, 5}, {f()})
      assert.same({3, 4, 5}, {f(1, 2, 3)})
    end)
  end)

  describe("identity(...)", function()
    it("is an identity f(x) = x function", function()
      assert.equal(1, fn.identity(1))
      assert.equal("a", fn.identity("a"))
      assert.same({6, 7}, {fn.identity(6, 7)})
    end)
  end)

  describe("curry", function()
    it("curries first arguments", function()
      local f = function(a, b, c)
        return a ^ 1 + b ^ 2 + c ^ 3
      end

      local g = fn.curry(f, 2, 2)

      assert.equal(6, g(0))
      assert.equal(7, g(1))
      assert.equal(14, g(2))
    end)
  end)
end)
