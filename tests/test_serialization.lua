local serpent = require("lib.serpent")
local vector = require("lib.vector")


local dump = function(x)
  return serpent.dump(x, {metatostring = false})
end

describe("Global serialization process", function()
  describe("package data handling", function()
    it("should not have issues with Theseus's Paradox", function()
      local package_path = "tests.resources.package"
      local serialized = dump(require(package_path))
      package.loaded[package_path] = nil

      assert.equal(require(package_path), load(serialized)())
    end)
  end)

  describe("metatable serialization", function()
    it("should work with our types", function()
      local v = vector({1, 2})
      assert.equal(v, load(dump(v))())
      assert.equal(v, vector.zero + v)
    end)

    it("should work with used love types", function()
      for _, x in ipairs({
        love.graphics.newImage("tests/resources/image.png"),
        love.audio.newSource("tests/resources/sound.mp3"),
      }) do
        assert.equal(x, load(dump(x))())
      end
    end)
  end)
end)
