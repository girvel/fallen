local tags, module_mt, static = Module("state.gui.creator.tags")

tags.anchor = function(index)
  return Html.span {
    Html.span {
      on_update = function(self)
        self.sprite.text = State.gui.creator._current_selection_index == index
          and ">"
          or " "
      end,
      " ",
    },
    "  ",
  }
end

local button_char = {
  [-1] = "<",
  [1] = ">",
}

tags.button = function(index, dx)
  return Html.span {
    button_char[dx],
    on_click = function()
      State.gui.creator._movement_functions[index](dx)
      State.gui.creator:refresh()
    end,
    on_hover = function(self)
      self.sprite.text[1] = Colors.green()
    end,
    on_hover_end = function(self)
      self.sprite.text[1] = Colors.dark_red()
    end,
    color = Colors.dark_red(),
  }
end

return tags