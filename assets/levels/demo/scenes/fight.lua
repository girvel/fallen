local api = require("tech.railing").api


return function()
  return {
    player_attacks_half_orc = {
      name = "Player attacks half-orc",
      enabled = true,
      start_predicate = function(self, rails) return rails.entities[3].hp < rails.old_hp[3] end,
      run = function(self, rails)
        self.enabled = false
        rails.entities[3].faction = "rebellion"
        State:start_combat({State.player, rails.entities[3]})
      end,
    },

    player_attacks_dreamer = {
      name = "Player attacks one of the dreamers",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return Fun.iter({1, 2, 4})
          :any(function(i) return rails.entities[i].hp < rails.old_hp[i] end)
      end,

      run = function(self, rails, dt)
        self.enabled = false
        rails.scenes.second_rotates_valve.enabled = false
        rails.scenes.player_wins_dreamers.enabled = true
        rails.scenes.player_attacks_half_orc.enabled = false

        State.player.faction = "rebellion"
        rails.entities[3].faction = "rebellion"

        local engineers = Fun.range(1, 4):map(function(i) return rails.entities[i] end):totable()
        State:start_combat(Tablex.concat({State.player}, engineers))
        Fun.iter(engineers):each(function(e)
          if e._highlight then
            State:remove(e._highlight)
            e._highlight = nil
          end
        end)
        rails.entities[3].run_away_to = rails.positions.exit

        api.order(rails, "Это была ошибка")
        api.wait_seconds(5)
        api.order(rails, "Устранить агрессивных инженеров")
      end,
    },

    player_wins_dreamers = {
      name = "Player wins the fight against dreamers",
      enabled = false,
      start_predicate = function(self, rails, dt)
        return State.player.hp > 0 and not State.move_order
      end,

      run = function(self, rails, dt)
        self.enabled = false
        api.order(rails, "Задача выполнена неудовлетворительно")
        api.order(rails, "Ожидайте следующее задание")
      end,
    },

    {
      name = "Half-orc runs away",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return rails.entities[3].run_away_to == rails.positions.exit
          and rails.entities[3].position == rails.positions.exit
      end,

      run = function(self, rails, dt)
        self.enabled = false
        api.wait_seconds(0.5)
        State:remove(rails.entities[3])
      end,
    },
  }
end
