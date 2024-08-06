local dump = require("lib.dump")

describe("Serialization library", function()
  describe("basic functionality", function()
    it("dumps a number", function()
      assert.are_equal(1, load(dump(1))())
    end)

    it("dumps a string", function()
      assert.are_equal("abc\n", load(dump("abc\n"))())
    end)

    it("dumps a function", function()
      local f = function()
        return true
      end
      assert.is_true(load(dump(f))()())
    end)

    it("dumps a nil", function()
      assert.is_nil(load(dump(nil))())
    end)

    it("dumps a boolean", function()
      assert.are_equal(true, load(dump(true))())
    end)
  end)

  describe("complex functionality", function()
    it("dumps a shallow table", function()
      local t = {a = 1, 3}
      assert.are_same(load(dump(t))(), t)
    end)

    it("dumps a shallow table with strange keys", function()
      local t = {["function"] = 1, ["//"] = 2}
      assert.are_same(load(dump(t))(), t)
    end)

    it("dumps a table in a table", function()
      local t = {a = {a = 1}}
      assert.are_same(load(dump(t))(), t)
    end)

    it("handles metatables", function()
      local t = setmetatable({a = {a = 1}}, {__call = function(self) return self.a.a end})
      assert.are_same(1, load(dump(t))()())
    end)

    it("handles function's upvalues", function()
      local a = 1
      local b = 2
      local f = function() return a + b end
      assert.are_same(3, load(dump(f))()())
    end)
  end)

  describe("graph handling", function()
    it("handles multiple references to the same table", function()
      local o = {}
      local t = {o = o, t = {}}
      t.t.o = o
      local result = load(dump(t))()
      assert.are_same(t, result)
      assert.are_equal(result.t.o, result.o)
    end)

    it("handles circular references", function()
      local t = {a = {}, b = {}}
      t.a.b = t.b
      t.b.a = t.a
      local result = load(dump(t))()
      assert.are_same(t, result)
      assert.are_equal(result.a.b, result.b)
      assert.are_equal(result.b.a, result.a)
    end)

    it("handles references to itself", function()
      local t = {}
      t.t = t
      local result = load(dump(t))()
      assert.are_same(t, result)
      assert.are_equal(result, result.t)
    end)

    it("handles tables as keys", function()
      local t = {}
      t[t] = t
      local result = load(dump(t))()
      assert.are_same(t, result)
      assert.are_equal(result[result], result)
    end)
  end)

  describe("special functionality", function()
    it("uses metatable's serialize", function()
      local t = setmetatable({}, {__serialize = function(self) return [[1]] end})
      assert.are_same(1, load(dump(t))())
    end)

    it("handles __serialize returning function", function()
      local t = setmetatable({a = 1}, {
        __serialize = function(self)
          local a = self.a
          return function()
            return a
          end
        end
      })

      assert.are_same(1, load(dump(t))())
    end)
  end)
end)
