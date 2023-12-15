import curses
import time
from dataclasses import dataclass, field
from typing import Any, Optional


@dataclass
class KeyReader:
    _window: curses.window
    debug_track: Optional[Any]

    total_waiting_time: float = 0

    def read_key(self, hotkeys=None, allow_empty=False) -> int | None:
        if self.debug_track is not None:
            hotkey = ord(next(self.debug_track))
        else:
            while (hotkey := self._read_key_from_curses()) == -1 and not allow_empty: pass

        if hotkeys is None or hotkey in hotkeys:
            return hotkey

    def _read_key_from_curses(self):
        t = time.time()
        result = self._window.getch()
        self.total_waiting_time += time.time() - t
        return result

