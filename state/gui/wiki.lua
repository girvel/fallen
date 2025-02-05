local sound = require("tech.sound")
local quest = require("tech.quest")
local texting = require("tech.texting")
local constants = require("tech.constants")


local load_wiki = function(path)
  local pattern = "^(.*).html$"
  local loaded_pages = Fun.iter(love.filesystem.getDirectoryItems(path))
    :filter(function(name) return name:find(pattern) end)
    :map(function(name)
      local _, _, codename = name:find(pattern)
      return {codename, texting.parse(love.filesystem.read(path .. "/" .. name))}
    end)
    :totable()

  table.sort(loaded_pages, function(a, b)
    local title_a = a[2]:get_title()
    local title_b = b[2]:get_title()

    local appendix = "Приложение"
    if title_a:starts_with(appendix) then
      if not title_b:starts_with(appendix) then
        return false
      end
    elseif title_b:starts_with(appendix) then
      return true
    end

    return title_a < title_b
  end)

  loaded_pages = Fun.iter(loaded_pages):map(unpack):tomap()

  loaded_pages.codex
    :find_by_name("body")
    :find_by_name("content").content
  = Fun.iter(loaded_pages)
    :filter(function(page_name) return page_name ~= "codex" end)
    :map(function(page_name, page)
      return Html.li {
        ["if"] = function(args)
          return page.attributes["if"](args)
        end,
        Html.a {
          href = page_name,
          page:get_title(),
        }
      }
    end)
    :totable()

  return loaded_pages
end

return Module("state.gui.wiki", function(gui)
  return {
    pages = load_wiki("assets/html/wiki"),
    codex = {},
    history = {},
    current_history_index = 0,
    text_entities = nil,

    quests = {},
    quest_states = {},

    styles = Table.extend({}, gui.styles, {
      default = {
        font_size = 14,
        color = Colors.white,
      },
      h1 = {
        font_size = 24,
      },
      h2 = {
        font_size = 20,
      },
    }),

    _open_sound = sound.multiple("assets/sounds/open_wiki", 0.3),
    _close_sound = sound.multiple("assets/sounds/close_wiki.mp3"),

    show = function(self, id)
      assert(self.pages[id], "Wiki page \"%s\" does not exist" % id)
      if self.history[self.current_history_index] ~= id then
        self.history = Fun.iter(self.history)
          :take_n(self.current_history_index)
          :chain({id})
          :totable()

        self.current_history_index = self.current_history_index + 1
      end
      self:_render_current_page()
    end,

    show_journal = function(self)
      self.history = {"journal"}
      self.current_history_index = 1
      self.pages.journal = self:_generate_journal()
      self:_render_current_page()
    end,

    _generate_journal = function(self)
      local content = {
        Html.h1 {"Журнал задач"},
        Fun.iter(self.quests)
          :filter(function(name) return self.quest_states[name] end)
          :map(function(name, this_quest)
            local state_n = self.quest_states[name]
            local status = ""
            local status_color = Colors.gray
            if state_n == quest.COMPLETED then
              status = " - завершено"
              state_n = math.huge
            elseif state_n == quest.FAILED then
              status = " - провалено"
              state_n = math.huge
            end

            return Html.p {
              Html.h2 {
                Html.span {
                  color = state_n > #this_quest.tasks
                    and Colors.from_hex("8b7c99")
                    or Colors.white,
                  this_quest.header,
                },
                Html.span {
                  color = status_color,
                  status,
                },
              },
              Fun.iter(this_quest.tasks)
                :take_n(state_n)
                :enumerate()
                :map(function(i, task)
                  return Html.span {
                    color = i == state_n
                      and Colors.white
                      or Colors.from_hex("8b7c99"),
                    Html.li {task},
                  }
                end)
                :unpack()
            }
          end)
          :unpack()
      }

      return Html.html {Html.body(content)}
    end,

    _render_current_page = function(self)
      sound.play(self._open_sound)
      self:_close_page()
      local id = self.history[self.current_history_index]

      local page = self.pages[id] or "~ Нет информации ~"

      local args = {
        codex = self.codex,
        pages = self.pages,
        api = require("tech.railing").api,
      }

      self.text_entities = State:add_multiple(texting.generate(
        page, self.styles, constants.TEXT_MAX_SIZE[1], "wiki", args
      ))
    end,

    _close_page = function(self)
      if not self.text_entities then return end
      State:remove_multiple(self.text_entities)
      self.text_entities = nil
    end,

    exit = function(self)
      sound.play(self._close_sound)
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
