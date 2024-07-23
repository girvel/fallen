local api = require("tech.railing").api
local special = require("tech.special")
local engineer_ai = require("library.engineer_ai")


return function()
  return {
    player_attacks_half_orc = {
      name = "Player attacks half-orc",
      enabled = true,
      start_predicate = function(self, rails)
        return Fun.iter(State.agression_log)
          :any(function(pair)
            return Tablex.shallow_same(pair, {State.player, rails.entities[3]})
          end)
      end,
      run = function(self, rails)
        self.enabled = false
        rails.scenes.half_orc_begs.enabled = true
        rails.entities[3].faction = "rebellion"
        State:start_combat({State.player, rails.entities[3]})
      end,
    },

    half_orc_begs = {
      name = "Half-orc begs for his life",
      enabled = false,
      start_predicate = function(self, rails, dt)
        return rails.entities[3].hp <= rails.old_hp[3] / 2
      end,

      run = function(self, rails, dt)
        self.enabled = false
        rails.entities[3].ai.mode = engineer_ai.modes.skip_turn()
        State:add(special.floating_line("Стой! Остановись, мужик!!!", rails.entities[3].position))
      end,
    },

    player_attacks_dreamer = {
      name = "Player attacks one of the dreamers",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return Fun.iter({1, 2, 4})
          :any(function(i)
            return Fun.iter(State.agression_log)
              :any(function(pair)
                return Tablex.shallow_same(pair, {State.player, rails.entities[i]})
              end)
          end)
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
        rails.entities[3].ai.mode = engineer_ai.modes.run_away_to(rails.positions.exit)

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
        State.gui.wiki.discovered_pages.dreamers = 2
        State.gui.wiki.discovered_pages.codex = 2
        api.order(rails, "Задача выполнена неудовлетворительно")
        api.wait_seconds(10)
        api.order(rails, "Ожидайте следующее задание")
      end,
    },

    {
      name = "Half-orc runs away",
      enabled = true,
      start_predicate = function(self, rails, dt)
        Log.trace(getmetatable(rails.entities[3].ai.mode) == getmetatable(engineer_ai.modes.run_away_to(rails.positions.exit)))
        Log.trace(rails.entities[3].ai.mode.enum_variant == engineer_ai.modes.run_away_to().enum_variant)
        return rails.entities[3].ai.mode == engineer_ai.modes.run_away_to(rails.positions.exit)
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
