import functools
import logging
import math
import random
from collections.abc import Sequence
from importlib.util import spec_from_file_location, module_from_spec
from pathlib import Path
from typing import TypeVar, Any

from src.engine.output.colors import ColorPair


def to_camel_case(snake_str):
    return "".join(x.capitalize() for x in snake_str.lower().split("_"))

def from_snake_case(snake_str: str):
    return snake_str.strip("_").replace("_", " ")

def soft_capitalize(string: str):
    return string[0].upper() + string[1:]

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

T = TypeVar("T")
TDefault = TypeVar("TDefault")
def random_choice_or(collection: Sequence[T], default: TDefault = None) -> T | TDefault:
    if len(collection) == 0: return default
    return random.choice(collection)

def random_round(number: float) -> int:
    return math.floor(number) + (chance(number % 1) and 1 or 0)

def import_module(p: Path):
    spec = spec_from_file_location(p.stem, p)
    module = module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

def add_multiline_string(
    window, y: int, x: int, padding_y: int, padding_x: int, h: int, w: int, text: str, color: ColorPair = ColorPair(),
) -> tuple[int, int]:
    while True:
        if y >= h - padding_y:
            logging.warning(f"Cut the text '{text}'")
            return y, x

        line = text[:w - padding_x - x]
        text = text[len(line):]

        window.addstr(y, x, line, color.to_curses())
        x += len(line)

        if text == "":
            return y, x

        y += 1
        x = padding_x

def crash_safe(f):
    @functools.wraps(f)
    def result(*args, **kwargs):
        try:
            return f(*args, **kwargs)
        except Exception as ex:
            logging.error(f"System {f} crashed with {args=}; {kwargs=}", exc_info=ex)

    return result

def set_function_value(dictionary: dict, key: Any):
    def decorator(value):
        dictionary[key] = value
        return value

    return decorator
