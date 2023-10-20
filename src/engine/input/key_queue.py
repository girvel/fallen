import curses
import logging
from dataclasses import dataclass, field
from typing import Any, Optional


@dataclass
class KeyQueue:
    _window: curses.window
    debug_track: Optional[Any]
    _list: list[int] = field(default_factory=list)

    def read_key(self, hotkeys=None, allow_empty=False):
        if len(self._list) > 0 and (hotkeys is None or self._list[0] in hotkeys):
            hotkey, *self._list = self._list
            return hotkey

        if self.debug_track is not None:
            hotkey = ord(next(self.debug_track))
        else:
            while (hotkey := self._window.getch()) == -1 and not allow_empty: pass

        if hotkey not in (-1, curses.KEY_MOUSE):
            self._list.clear()

        if hotkeys is None or hotkey in hotkeys:
            return hotkey

        self._list.append(hotkey)
