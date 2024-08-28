local quest = require("tech.quest")
local texting = require("tech.texting")
local html = require("tech.texting.html")


local load_wiki = function(path)
  local pattern = "^(.*).html$"
  local loaded_pages = Fun.iter(love.filesystem.getDirectoryItems(path))
    :filter(function(name) return name:find(pattern) end)
    :map(function(name)
      local _, _, codename = name:find(pattern)
      return {codename, love.filesystem.read(path .. "/" .. name)}
    end)
    :totable()

  table.sort(loaded_pages, function(a, b)
    local title_a = html.get_title(a[2])
    local title_b = html.get_title(b[2])

    local appendix = "Приложение"
    if title_a:startsWith(appendix) then
      if not title_b:startsWith(appendix) then
        return false
      end
    elseif title_b:startsWith(appendix) then
      return true
    end

    return title_a < title_b
  end)

  loaded_pages = Fun.iter(loaded_pages):map(unpack):tomap()

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

return Module("state.gui.wiki", function()
  return {
    pages = load_wiki("assets/wiki"),
    codex = {},
    history = {},
    current_history_index = 0,
    text_entities = nil,

    quests = {},
    quest_states = {},

    styles = {
      default = {
        font_size = 12,
        color = Colors.white,
      },
      h1 = {
        font_size = 24,
      },
      h1_prefix = {
        font_size = 24,
        color = Colors.dark_red,
      },
      h2 = {
        font_size = 16,
      },
      h2_prefix = {
        font_size = 16,
        color = Colors.dark_red,
      },
      a = {
        color = Common.hex_color("3f5d92"),
      },
      hate = {
        color = Colors.red,
        delay = 0.1,
        appearance_time = .4,
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
        :filter(function(name) return self.quest_states[name] end)
        :map(function(name, this_quest)
          local state_n = self.quest_states[name]
          local status = ""
          local status_color = Colors.hex.gray
          if state_n == quest.COMPLETED then
            status = " - завершено"
            state_n = math.huge
          elseif state_n == quest.FAILED then
            status = " - провалено"
            state_n = math.huge
          end

          return [[
            <ul>
              <h2><span color="%s">%s</span><span color="%s">%s</span></h2>
              %s
            </ul>
          ]] % {
            state_n > #this_quest.tasks and "8b7c99" or Colors.hex.white,
            this_quest.header,
            status_color, status,
            Fun.iter(this_quest.tasks)
              :take_n(state_n)
              :enumerate()
              :map(function(i, task) return [[
                <span color="%s"><li>%s</li></span>
              ]] % {i == state_n and Colors.hex.white or "8b7c99", task} end)
              :reduce(function(sum, v) return v .. sum end, "")
          }
        end)
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
        api = require("tech.railing").api,
      }

      html.run_scripts(page, args)
      self.text_entities = State:add_multiple(texting.generate(
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
end)
