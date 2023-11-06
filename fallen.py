"""CLI and launch script for Fallen"""

import curses
import logging
from pathlib import Path
from time import time
from typing import Optional

import fire

from src import init_ecs
from src.init_logging import init_logging


def main(
    track_file: Optional[str] = None,
    debug_mode: bool = False,
    no_render: bool = False,
    no_rails: bool = False,
    no_fixed_fps: bool = False,
    pause_for_debugger: bool = False,
):
    """
    Launch the Fallen RPG

    Args:
        track_file: file to redirect input from
        debug_mode: whether to enable debug console & utilities
        no_render: whether to disable render
        no_rails: disable level's rails
        no_fixed_fps: disable fixed FPS
        pause_for_debugger: wait for 'Enter' key (useful for debugger connection)
    """

    init_logging()
    logging.info("Started")

    track = track_file and Path(track_file).read_text().replace("\n", "")

    if pause_for_debugger:
        input()

    curses.wrapper(init_ecs.init,
        track=track,
        debug_mode=debug_mode,
        no_render=no_render,
        no_rails=no_rails,
        no_fixed_fps=no_fixed_fps,
    )


if __name__ == '__main__':
    fire.Fire(main)
