local patch, module_mt, static = Module("lib.tiny_dump_patch")

module_mt.__call = function(_)
  Tiny.worldMetaTable.__serialize = function(self)
    local entities = self.entities
    local systems = self.systems
    return function()
      for k, v in pairs(package.loaded) do
        if k:startsWith("systems") then
          package.loaded[k] = nil
        end
      end

      local result = Tiny.world(unpack(require("systems")))
      for _, e in ipairs(entities) do
        result:add(e)
      end
      return result
    end
  end
end

return patch
