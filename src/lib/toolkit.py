import math
import random


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
