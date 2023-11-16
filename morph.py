import fire

from src.engine.language.name import Name, _analyzer


def main(word):
    for i in range(len([0 for p in _analyzer.parse(word) if "nomn" in p.tag])):
        print(i, repr(Name.auto(word, i)))


if __name__ == "__main__":
    fire.Fire(main)
