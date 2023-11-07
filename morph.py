import fire

from src.engine.naming.name import Name, _analyzer


def main(word):
    for i in range(len(_analyzer.parse(word))):
        print(i, repr(Name.auto(word, i)))


if __name__ == "__main__":
    fire.Fire(main)
