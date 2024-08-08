local patch, module_mt, static = Module("lib.tiny_dump_patch")

module_mt.__call = function(_)
  Tiny.worldMetaTable.__serialize = function(self)
    local entities = self.entities
    local systems = self.systems
    return function()
      local result = Tiny.world(unpack(systems))
      for _, e in ipairs(entities) do
        result:add(e)
      end
      return result
    end
  end
end

return patch
