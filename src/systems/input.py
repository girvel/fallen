import logging

from ecs import create_system


log = logging.getLogger(__name__)


@create_system
def read_input(controller: 'hotkeys, controls', screen: 'screen_flag', level: 'level_grid'):
    pass
    # while True:
    #     hotkey = screen.main.getkey()
    #     if hotkey in controller.hotkeys:
    #         break
    #     log.debug(f"Ignored: [{hotkey}]")
    #     log.debug(controller.hotkeys)
    #
    # log.debug(f"[{hotkey}]")
    # controller.hotkeys[hotkey](level.level_grid, screen)
