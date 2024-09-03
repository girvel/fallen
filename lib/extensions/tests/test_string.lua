describe("lib.extensions.string", function()
  local mt = {__index = {}}
  local stringx = setmetatable({}, mt)
  require("lib.extensions.string").inject(mt)

  describe("utf_sub", function()
    it("performs UTF8-compatible substring", function()
      assert.equal("Приве", stringx.utf_sub("Привет, мир!", 1, 5))
    end)

    it("handles missing last argument case", function()
      assert.equal(", мир!", stringx.utf_sub("Привет, мир!", 7))
    end)

    it("handles negative last argument", function()
      assert.equal("ет, ми", stringx.utf_sub("Привет, мир!", 5, -3))
    end)
  end)

  describe("utf_len", function()
    it("returns the correct length for UTF8 string", function()
      assert.equal(12, stringx.utf_len("Привет, мир!"))
    end)
  end)

  describe("utf_lower", function()
    it("lowers all characters in a UTF8 string", function()
      assert.equal("привет, мир!", stringx.utf_lower("пРиВЕт, МИр!"))
    end)
  end)

  describe("utf_upper", function()
    it("uppers all characters in a UTF8 string", function()
      assert.equal("ПРИВЕТ, МИР!", stringx.utf_upper("пРиВЕт, МИр!"))
    end)
  end)
end)
