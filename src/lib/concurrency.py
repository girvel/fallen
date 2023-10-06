import time
from typing import Callable


def wait_for(ticks_n: int):
    for _ in range(ticks_n):
        yield

def wait_while(predicate: Callable[[], bool]):
    while predicate(): yield

def wait_seconds(seconds: float):
    t = time.time()
    while time.time() - t < seconds: yield
