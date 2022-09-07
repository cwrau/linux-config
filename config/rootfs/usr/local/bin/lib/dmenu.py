from typing import Sequence

import dynmen
from dynmen import Menu, MenuResult, MenuError


def dmenu(items: Sequence[str], active_indices: Sequence[int] = None, prompt: str = "dmenu") -> int:
    args: list[str] = ["dmenu", "-format", "i", "-i", "-p", prompt]
    if active_indices:
        args += ["-a", ",".join([str(i) for i in active_indices])]
    menu: Menu = dynmen.Menu(args)

    try:
        result: MenuResult = menu(items)
        if result.selected is None:
            return -1
        else:
            return int(result.selected)
    except MenuError:
        return -1
