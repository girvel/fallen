local mech = require("mech")


local combat, module_mt = Static.module("tech.combat")

combat.TURN_END_SIGNAL = 666
combat.WORLD_TURN = {codename = "WORLD_TURN"}

module_mt.__call = function(_, list)
  Fun.iter(list)
    :filter(function(e) return mech.are_hostile(e, State.player) end)
    :each(function(e)  end)
  return {
    list = Fun.iter(list)
      :filter(function(e) return State:exists(e) end)
      :chain({combat.WORLD_TURN})
      :totable(),
    current_i = 1,
    remove = function(self, item)
      self.list = Fun.iter(self.list)
        :enumerate()
        :filter(function(i, e)
          if e ~= item then return true end
          if i < self.current_i then self.current_i = self.current_i - 1 end
        end)
        :map(function(_, e) return e end)
        :totable()
    end,
    get_current = function(self)
      return self.list[self.current_i]
    end,
    move_to_next = function(self)
      self.current_i = self.current_i + 1
      if self.current_i > #self.list then
        self.current_i = 1
      end
    end,
    iter_entities_only = function(self)
      return Fun.iter(self.list)
        :filter(function(e) return e ~= combat.WORLD_TURN end)
    end,
  }
end

return combat
