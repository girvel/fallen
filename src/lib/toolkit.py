import logging
import math
import random
from importlib.util import spec_from_file_location, module_from_spec
from pathlib import Path

from src.engine.output.colors import Colors


def to_camel_case(snake_str):
    return "".join(x.capitalize() for x in snake_str.lower().split("_"))

def from_snake_case(snake_str: str):
    return snake_str.strip("_").replace("_", " ")

def sign(n):
    if n == 0:
        return 0
    if n < 0:
        return -1
    return 1

def cut_by_length(string, length):
    return [string[i:i + length] for i in range(0, len(string), length)]

curses_wrong_characters = {
    0: "]",
    460: '"',
    530: "'",
    529: "CTL_ENTER",
}

def death_chance_from_half_life(half_life):
    return 1 - .5 ** (1 / half_life)

def chance(p):
    return random.random() <= p

def random_round(number: float) -> int:
    return math.floor(number) + (chance(number % 1) and 1 or 0)

def import_module(p: Path):
    spec = spec_from_file_location(p.stem, p)
    module = module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

def add_multiline_string(
    window, y: int, padding_w: int, h: int, w: int, line: str, color: Colors = Colors.Default,
) -> int:
    i = -1
    for i, l in enumerate(cut_by_length(line, w - padding_w * 2)):
        if y + i >= h:
            logging.warning(f"The line is too long to display: '{line}'")
            return y + i

        window.addstr(y + i, 2, l, color.format())

    return y + i + 1
