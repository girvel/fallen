local texting = require("state.gui.texting")
local html = require("state.gui.texting.html")


local font_path = "assets/fonts/joystix.monospace-regular.otf"

local load_wiki = function(path)
  local pattern = "^(.*).html$"
  local loaded_pages = Fun.iter(love.filesystem.getDirectoryItems(path))
    :filter(function(name) return name:find(pattern) end)
    :map(function(name)
      local _, _, codename = name:find(pattern)
      return codename, love.filesystem.read(path .. "/" .. name)
    end)
    :tomap()

  loaded_pages.codex = loaded_pages.codex % Fun.iter(loaded_pages)
    :filter(function(page) return page ~= "codex" end)
    :map(function(page, content)
      return '<li if="html.is_available(pages.%s, args)"><a href="%s">%s</a></li>\n' % {
        page, page, html.get_title(content),
      }
    end)
    :reduce(Fun.op.concat, "")

  return loaded_pages
end

return function()
  return {
    pages = load_wiki("assets/wiki"),
    codex = {},
    history = {},
    current_history_index = 0,
    text_entities = nil,

    quests = {},
    quests_states = {},

    styles = {
      default = {
        font = love.graphics.newFont(font_path, 12),
        color = Common.hex_color("ededed"),
      },
      h1 = {
        font = love.graphics.newFont(font_path, 24),
      },
      h1_prefix = {
        font = love.graphics.newFont(font_path, 24),
        color = Common.hex_color("5d375a"),
      },
      h2 = {
        font = love.graphics.newFont(font_path, 16),
      },
      h2_prefix = {
        font = love.graphics.newFont(font_path, 16),
        color = Common.hex_color("5d375a"),
      },
      a = {
        color = Common.hex_color("3f5d92"),
      },
      hate = {
        color = Common.hex_color("e64e4b"),
        delay = 0.2,
        appearance_time = 2,
      },
    },

    show = function(self, id)
      assert(self.pages[id], "Wiki page \"%s\" does not exist" % id)

      self.history = Fun.iter(self.history)
        :take_n(self.current_history_index)
        :chain({id})
        :totable()

      self.current_history_index = self.current_history_index + 1
      self:_render_current_page()
    end,

    show_journal = function(self)
      self.history = {"journal"}
      self.current_history_index = 1
      self.pages.journal = [[
        <html>
          <body>
            <h1>Журнал задач</h1>
            %s
          </body>
        </html>
      ]] % Fun.iter(self.quests)
        :filter(function(name) return self.quests_states[name] end)
        :map(function(name, quest) return [[
          <ul>
            <h2><span color="%s">%s</span></h2>
            %s
          </ul>
        ]] % {
          self.quests_states[name] > #quest.tasks and "8b7c99" or "ededed",
          quest.header,
          Fun.iter(quest.tasks)
            :take_n(self.quests_states[name])
            :enumerate()
            :map(function(i, task) return [[
              <span color="%s"><li>%s</li></span>
            ]] % {i == self.quests_states[name] and "ededed" or "8b7c99", task} end)
            :reduce(function(sum, v) return v .. sum end, "")
        } end)
        :reduce(Fun.op.concat, "")
        self:_render_current_page()
    end,

    _render_current_page = function(self)
      self:_close_page()
      local id = self.history[self.current_history_index]

      local page = self.pages[id] or "~ Нет информации ~"

      local args = {
        codex = self.codex,
        pages = self.pages,
        html = html,
      }

      html.run_scripts(page, args)
      self.text_entities = State:add_multiple(texting.generate_html_page(
        page, self.styles, State.gui.TEXT_MAX_SIZE[1], "wiki", args
      ))
    end,

    _close_page = function(self)
      if not self.text_entities then return end
      State:remove_multiple(self.text_entities)
      self.text_entities = nil
    end,

    exit = function(self)
      self:_close_page()
      self.history = {}
      self.current_history_index = 0
    end,

    move_in_history = function(self, direction)
      assert(direction == -1 or direction == 1)

      if
        direction < 0 and self.current_history_index <= 1 or
        direction > 0 and self.current_history_index == #self.history
      then
        return
      end

      self.current_history_index = self.current_history_index + direction
      self:_render_current_page()
    end,
  }
end
