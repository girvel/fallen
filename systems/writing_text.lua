local writing_text, module_mt, static = Module("systems.writing_text")

writing_text.system = static(Tiny.system({
  codename = "writing_text",
  base_callback = "textinput",
  update = function(self, event)
    State.gui.text_input.text = State.gui.text_input.text .. event[1]
  end
}))

return writing_text