from typing import TypeVar, Callable

from dynmen import MenuError

from .dmenu import *
from .notify import *

ITEM: TypeVar = TypeVar('ITEM')


def get_choice(items: Sequence[ITEM], item_name: str, name_getter: Callable[[ITEM], str], title: str,
               active_selector: Callable[[ITEM], bool] = None, auto_select: bool = False) -> ITEM | None:
    if len(items) == 0:
        notify(title, f"No {item_name} available")
        return None
    elif auto_select and len(items) == 1:
        item: ITEM = items[0]
        notify(title,
               f"Chose '{name_getter(item)}', as it was the only {item_name}")
    else:
        names: Sequence[str] = [name_getter(it) for it in items]
        if active_selector is None:
            selection: int = dmenu(names)
        else:
            selection: int = dmenu(names, [
                index for index, item in enumerate(items) if
                active_selector(item)
            ], item_name)

        if selection < 0:
            return None

        item = items[selection]

    return item
