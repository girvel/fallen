from ecs import create_system

def generate_removal(component):  # TODO move to acting
    @create_system
    def result(container: component):
        delattr(container, component)

    return result

remove_temporals = [generate_removal(c) for c in ["receives_damage"]]
