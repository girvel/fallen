from src.engine.output.windows.panes.pane import Pane


class Inventory(Pane):
    template_name = "inventory.html"
    name = "Инвентарь"

    def get_arguments(self, subject, perception):
        return {
            "inventory": subject.inventory,
        }
