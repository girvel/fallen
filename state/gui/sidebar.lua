local gui = require("tech.gui")
local hostility = require("mech.hostility")
local translation = require("tech.translation")
local sound = require("tech.sound")
local actions = require("mech.creature.actions")


local COLOR = {
  INACTIVE = Colors.gray,
  HOSTILE = Colors.red,
}

local value_translations = {
  [true] = "да",
  [false] = "нет",
}

return Module("state.gui.sidebar", function()
  return {
    action_entities = {},
    hp_bar = nil,
    hp_text = nil,

    last_mode = nil,
    hovered_icon = nil,

    ACTION_GRID_W = 5,
    W = 320,

    _hidden = false,

    -- TODO REF move notification to a separate module
    update = function(self, dt)
      self:_update_hp_bar()
      if self.last_mode ~= State.mode:get() then
        self:refresh_action_grid()
        self.last_mode = State.mode:get()
      end
    end,

    _update_hp_bar = function(self)
      local text = "%s/%s" % {State.player.hp, State.player:get_max_hp()}
      local font = self.hp_text.sprite.font

      local hp_bar = self.hp_bar
      local hp_bar_view = State.gui.views[hp_bar.view]
      self.hp_text.sprite.text = text
      self.hp_text.position = hp_bar.position * hp_bar_view:get_multiplier() + Vector({
        (hp_bar.sprite.image:getWidth() * hp_bar_view:get_multiplier() - font:getWidth(text)) / 2,
        2
      })

      hp_bar.sprite.quad = love.graphics.newQuad(
        0, 0,
        hp_bar.sprite.image:getWidth() * math.min(1, State.player.hp / State.player:get_max_hp()),
        hp_bar.sprite.image:getHeight(),
        hp_bar.sprite.image:getDimensions()
      )
    end,

    initialize = function(self)
      State:add(gui.gui_background())
      self.hp_bar = State:add(gui.hp_bar())
      self.hp_text = State:add(gui.hp_text())
      self:refresh_action_grid()
    end,

    hide = function(self)
      self._hidden = true
      State:remove_multiple(self.action_entities)
      self.action_entities = {}
    end,

    show = function(self)
      self._hidden = false
      self:refresh_action_grid()
    end,

    refresh_action_grid = function(self)
      if self._hidden then return end

      State:remove_multiple(self.action_entities)
      local player_actions = State.player.potential_actions
      self.action_entities = State:add_multiple(
        OrderedMap.iter(State.hotkeys[State.mode:get().codename])
          :filter(function(key, data)
            return data.codename
              and not -Query(data):hidden()
              and (not data.action or Table.contains(player_actions, data.action))
          end)
          :enumerate()
          :map(function(i, key, data)
            local frame = gui.action_frame(i)
            return {
              gui.action_icon(data, i, frame),
              frame,
              gui.action_hotkey(key, i),
            }
          end)
          :reduce(Table.concat, {})
      )
    end,

    get_text = function(self)
      local result = {}

      local append = function(content)
        if type(content) == "string" then
          content = {content}
        end
        if #result > 0
          and type(result[#result]) == "string"
          and type(content[1]) == "string"
        then
          result[#result] = result[#result] .. content[1]
          table.remove(content, 1)
        end
        Table.concat(result, content)
      end

      local main_weapon = -Query(State.player).inventory.main_hand
      if main_weapon then
        append("Оружие: %s\n\n" % main_weapon:to_display())
      end

      local second_weapon = -Query(State.player).inventory.other_hand
      if second_weapon then
        append("Второе оружие: %s\n\n" % second_weapon:to_display())
      end

      -- TODO move the bag out of rails, temporary hack for now to use polygon level
      if State.rails.bottles_taken then
        local bag = {}
        if State.rails.bottles_taken > 0 then
          table.insert(bag, {"Бутылки с алкоголем", tostring(State.rails.bottles_taken)})
        end
        if State.rails.has_valve then
          table.insert(bag, {"Вентиль", "1"})
        end
        if State.rails.has_sigi then
          table.insert(bag, {"Сигареты", "1"})
        end

        if #bag > 0 then
          append(Common.build_table(
            {"Сумка", ""},
            bag
          ) .. "\n\n")
        end
      end

      local shown_resources, max_resources
      do
        local move = State.player:get_resources("move")
        local short = State.player:get_resources("short")
        local long = State.player:get_resources("long")

        shown_resources = Table.extend({}, short, long)
        if State.mode:get() == State.mode.combat then
          Table.extend(shown_resources, move)
        end

        max_resources = Table.extend({}, move, short, long)
      end

      if next(shown_resources) then
        local table_render = Common.build_table(
          {"", ""},
          OrderedMap.iter(State.player.resources)
            :filter(function(k) return shown_resources[k] end)
            :map(function(k, v)
              return {
                translation.resources[k] or k,
                (value_translations[v] or tostring(v))
                  .. (max_resources[k] == nil
                    and ""
                    or "/" .. (value_translations[max_resources[k]] or tostring(max_resources[k])))
              }
            end)
            :totable()
        ) / "\n"

        append("Ресурсы\n")
        append(table_render[2])

        local highlighted = -Query(self.hovered_icon).hotkey_data.action.cost or {}

        local i = 3
        for k, v in Table.pairs(State.player.resources) do
          if not shown_resources[k] then goto continue end
          local color = Colors.white
          if highlighted[k] then
            if highlighted[k] > v then
              color = Colors.red
            else
              color = Colors.light_green
            end
          end
          append({
            color,
            "\n" .. table_render[i],
          })
          i = i + 1
          ::continue::
        end
      end

      if State.combat then
        append("\n\nОчередь ходов:")
        append(
          State.combat:iter_entities_only()
            :map(function(e)
              return {
                hostility.are_hostile(State.player, e) and COLOR.HOSTILE or Colors.white,
                "\n%s %s" % {
                  State.combat:get_current() == e and "x" or "-",
                  Entity.name(e),
                },
              }
            end)
            :reduce(Table.concat, {})
        )
      end

      return result
    end,
  }
end)
