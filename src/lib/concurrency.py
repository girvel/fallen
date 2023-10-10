import time
from typing import Callable

from src.lib.toolkit import random_round


def wait_for(ticks_n: int):
    for _ in range(ticks_n):
        yield

def wait_while(predicate: Callable[[], bool]):
    while predicate(): yield

def wait_seconds(seconds: float):
    yield from wait_for(random_round(seconds * 5))
