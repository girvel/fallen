from statistics import median

from ecs import create_system

from src.lib.vector import Vector

import logging

log = logging.getLogger(__name__)


@create_system
def camera_follow(screen: 'screen_flag', controller: 'controller_flag', level: 'level_grid'):
    h, w = screen.game.getmaxyx()

    screen.virtual_p = Vector(
        median((
            0,
            controller.controls.p.x - w + screen.following_offset.x,
            screen.virtual_p.x,
            controller.controls.p.x - screen.following_offset.x,
            level.size.x - w,
        )),
        median((
            0,
            controller.controls.p.y - h + screen.following_offset.y,
            screen.virtual_p.y,
            controller.controls.p.y - screen.following_offset.y,
            level.size.y - h,
        ))
    )
