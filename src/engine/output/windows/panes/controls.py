import curses

from src.engine.input.hotkeys import Key
from src.engine.input.mode import ALL_MODES
from src.engine.output.windows.panes.pane import Pane


class Controls(Pane):
    template_name = "controls.html"
    name = "Управление"

    pretty_hotkeys = {
        curses.KEY_MOUSE: "Mouse Key",
        curses.KEY_LEFT: "←",
        curses.KEY_RIGHT: "→",
        curses.KEY_UP: "↑",
        curses.KEY_DOWN: "↓",
        ord(" "): "␣",
        Key.enter: "⏎",
        Key.ctrl_c: "Ctrl+C",
        ord(""): "Esc",
    }

    def get_arguments(self, subject, perception):
        def reduce_hotkeys(hotkey_collection):
            result = {}

            for (key, hotkey) in hotkey_collection.items():
                if hotkey.hidden: continue
                entry = self.pretty_hotkeys.get(key, chr(key).capitalize() if key != -1 else " ")

                if hotkey.description in result:
                    result[hotkey.description] += ", " + entry
                else:
                    result[hotkey.description] = entry

            return result

        return {
            "hotkeys": {
                mode.name: reduce_hotkeys(self.io.input.hotkeys[mode])
                for mode
                in ALL_MODES
            }
        }
