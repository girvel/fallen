local lust = require("lib.lust")
local describe = lust.describe
local it = lust.it
local expect = lust.expect

local serpent = require("lib.serpent")
local vector = require("lib.vector")


local dump = function(x)
  return serpent.dump(x, {metatostring = false})
end

lust.describe("Global serialization process", function()
  describe("package data handling", function()
    it("should not have issues with Theseus's Paradox", function()
      local package_path = "tests.resources.package"
      local serialized = dump(require(package_path))
      package.loaded[package_path] = nil

      expect(load(serialized)()).to.be(require(package_path))
    end)
  end)

  describe("metatable serialization", function()
    it("should work with our types", function()
      local v = vector({1, 2})
      expect(load(dump(v))()).to.be(v)
      expect(vector.zero + v).to.be(v)
    end)

    it("should work with used love types", function()
      for _, x in ipairs({
        love.graphics.newImage("tests/resources/image.png"),
        love.audio.newSource("tests/resources/sound.mp3", "static"),
      }) do
        expect(load(dump(x))()).to.be(x)
      end
    end)
  end)
end)
