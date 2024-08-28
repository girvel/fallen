local process_scancodes, module_mt, static = Module("systems.process_scancodes")

process_scancodes.system = static(Tiny.system({
  codename = "process_scancodes",
  base_callback = "update",
  update = function(self, dt)
    Table.concat(State.player.action_factories, Fun.iter(State.gui.pressed_scancodes)
      :map(function(s) return -Query(State.hotkeys)[State:get_mode()][s] end)
      :filter(Fun.op.truth)
      :totable()
    )
    State.gui.pressed_scancodes = {}
  end,
}))

return process_scancodes
