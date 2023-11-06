import curses

from src.engine.input.hotkeys import Key
from src.engine.output.windows.panes.pane import Pane


class Controls(Pane):
    template_name = "controls.html"
    name = "Управление"

    pretty_hotkeys = {
        curses.KEY_MOUSE: "🐭",
        curses.KEY_LEFT: "←",
        curses.KEY_RIGHT: "→",
        curses.KEY_UP: "↑",
        curses.KEY_DOWN: "↓",
        ord(" "): "␣",
        Key.enter: "⏎",
        Key.ctrl_c: "Ctrl+C",
        ord(""): "Esc",
    }

    mode_translation = {  # TODO move to the Mode itself
        "global_": "Глобальные",
        "game": "Игра",
        "options": "Выбор варианта",
        "dialog_line": "Диалог",
        "cutscene": "Сцена",
        "notification": "Уведомление",
    }

    def get_arguments(self, subject, perception):
        def reduce_hotkeys(hotkey_collection):
            result = {}

            for (key, hotkey) in hotkey_collection.items():
                if hotkey.hidden: continue
                entry = self.pretty_hotkeys.get(key, chr(key) if key != -1 else " ")

                if hotkey.description in result:
                    result[hotkey.description] += ", " + entry
                else:
                    result[hotkey.description] = entry

            return result

        return {
            "hotkeys": {
                self.mode_translation[mode]: reduce_hotkeys(self.io.input.hotkeys[mode])
                for mode
                in ["global_", "game", "options", "dialog_line", "cutscene", "notification"]
            }
        }
