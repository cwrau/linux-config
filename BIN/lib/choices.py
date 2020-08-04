from .dmenu import *
from .notify import *


def get_choice(items, item_name, name_getter, title, active_selector=None,
               auto_select=False):
    if len(items) == 0:
        notify(title, f"No {item_name} available")
        return None
    elif auto_select and len(items) == 1:
        item = items[0]
        notify(title,
               f"Chose '{name_getter(item)}', as it was the only {item_name}")
    else:
        names = [name_getter(it) for it in items]
        if active_selector is None:
            selection = dmenu(names)
        else:
            selection = dmenu(names, [
                index for index, item in enumerate(items) if
                active_selector(item)
            ], item_name)

        if selection is None or selection < 0:
            return None

        item = items[selection]

    return item
