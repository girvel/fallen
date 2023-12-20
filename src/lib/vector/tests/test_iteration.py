from src.lib.vector.iteration import iter_rhombus_from_center


def test_iteration():
    assert list(iter_rhombus_from_center((0, 0), 2)) == [
        (0, 0), (0, -1), (1, 0), (0, 1), (-1, 0), (0, -2), (1, -1), (2, 0), (1, 1), (0, 2), (-1, 1), (-2, 0), (-1, -1)
    ]
