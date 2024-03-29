"""CLI and launch script for Fallen"""

import curses
import logging
import random
import time
from pathlib import Path
from typing import Optional

import fire
from ecs import exists

from src.engine import permanent_storage
from src.engine.input.hotkeys import GameEnd
from src.ecs import build_metasystem
from src.logging_setup import init_logging, log_stats
from src.assets.ais.io import IO
from src.assets.physical.player import Player
from src.assets.special.level import Level


def main(
    track_file: Optional[str] = None,
    debug_mode: bool = False,
    no_render: bool = False,
    no_rails: bool = False,
    no_fixed_fps: bool = False,
    skip_cutscenes: str = "",
    pause_for_debugger: bool = False,
    level_path: str = "levels/main_01_introduction",
    god_vision: bool = False,
    random_seed: str | None = None,
):
    """
    Launch the Fallen RPG

    Args:
        track_file: file to redirect input from
        debug_mode: whether to enable debug console & utilities
        no_render: whether to disable render
        no_rails: disable level's rails
        no_fixed_fps: disable fixed FPS
        skip_cutscenes: `:`-separated list of cutscenes to skip
        pause_for_debugger: wait for 'Enter' key (useful for debugger connection)
        level_path: level folder's full path
        god_vision: whether player sees everything
        random_seed: seed for random numbers generation
    """

    log_handler = init_logging()
    logging.info("Started")

    track = track_file and Path(track_file).read_text().replace("\n", "") or ""

    if pause_for_debugger:
        input()

    random_seed = random_seed or hex(random.randrange(0, 0xFFFFFF))
    random.seed(random_seed)
    logging.info(f"Seed is {random_seed!r}")

    @curses.wrapper
    def _launch(stdscr):
        permanent_storage.initialize()

        ms, hades, genesis = build_metasystem(debug_mode)

        # TODO loading screen

        level = Level.create(Path(level_path), hades, genesis, no_rails)

        # TODO should be inside the Level.create?
        prep_time = level.config.prep_ticks
        if prep_time > 0: logging.info(f"Prerunning the level for {prep_time} ticks")

        for _ in range(prep_time + 1):
            try:
                ms.update()
            except Exception as ex:
                logging.error("Uncaught error on Metasystem.update when prerunning the level", exc_info=ex)
                if debug_mode: raise ex

        player = next(level.find(Player))
        player.ai = IO(
            stdscr, debug_track=track, debug_mode=debug_mode,
            is_render_enabled=not no_render, is_fps_fixed=not no_fixed_fps,
            skipped_cutscenes=skip_cutscenes.split(':'),
        )

        if god_vision:
            player.god_vision_flag = None
            player.senses.vision = 1_000

        logging.info("Starting game cycle")

        t = time.time()
        update_counter = 0
        try:
            while exists(player):
                ms.update()
                update_counter += 1
        except GameEnd:
            pass
        except Exception as ex:
            logging.error("Uncaught error on Metasystem.update", exc_info=ex)
            if debug_mode: raise ex
        finally:
            t = time.time() - t - player.ai.input.key_reader.total_waiting_time

            logging.info("Finishing game cycle")
            if t > 0:
                logging.info(f"FPS: {update_counter / t:.2f}, ticks: {update_counter}")
            log_stats(log_handler)


if __name__ == '__main__':
    fire.Fire(main)
