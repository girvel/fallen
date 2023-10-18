from src.init_ecs import build_metasystem


def test_build():
    ms, genesis = build_metasystem(False)
    ms.update()

    assert True
