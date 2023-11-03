import curses


class Window:
    def __init__(self, io):
        self.curses_window = curses.newwin(1, 1, 0, 0)
        self.io = io
