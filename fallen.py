import curses
import logging

from src import init_ecs

log = logging.getLogger(__name__)

if __name__ == '__main__':
    logging.basicConfig(filename='.last.log', encoding='utf-8', level=logging.DEBUG)
    log.info("Started")

    logging.getLogger('numba').setLevel(logging.WARNING)

    curses.wrapper(init_ecs.init)
