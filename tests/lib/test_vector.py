from math import pi

from src.lib.vector import Vector, zero


def test_project():
    assert Vector(1, 0).project(Vector(0, 1)) == zero
    assert Vector(3, 4).project(Vector(0, 1)) == Vector(0, 4)


def test_scalar_project():
    assert Vector(1, 1).scalar_project(Vector(-1, 0)) == -1


def test_angle():
    assert Vector(1, -1).angle() - (-pi / 4) <= .01
