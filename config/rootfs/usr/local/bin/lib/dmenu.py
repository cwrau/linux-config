from typing import Sequence

import dynmen


def dmenu(items: Sequence[str], active_indices: Sequence[int] = None, prompt: str = "dmenu") -> int:
    args = ["dmenu", "-format", "i", "-i", "-p", prompt]
    if active_indices:
        args += ["-a", ",".join([str(i) for i in active_indices])]
    menu = dynmen.Menu(args)

    try:
        return int(menu(items).selected)
    except dynmen.MenuError:
        return -1
