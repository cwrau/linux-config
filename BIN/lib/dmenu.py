import dynmen


def dmenu(items, active_indices=None, prompt="dmenu"):
    args = ["dmenu", "-format", "i", "-i", "-p", prompt]
    if active_indices:
        args += ["-a", ",".join([str(i) for i in active_indices])]
    menu = dynmen.Menu(args)

    try:
        return int(menu(items).selected)
    except dynmen.MenuError:
        return -1
