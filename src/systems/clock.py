import logging

from src.components import Counting, TimeAware
from src.lib.time import Time

sequence = []

@sequence.append
def count_ticks(subject: Counting):
    subject.tick_counter += 1

@sequence.append
def count_time(subject: TimeAware):
    # subject.time += Time(seconds=6)  TODO NEXT
    subject.time += Time(minutes=1)
