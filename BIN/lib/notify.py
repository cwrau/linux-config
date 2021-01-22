import notify2

notify2.init("CWRScript")


def notify(title: str, message: str, timeout: int = 2000) -> None:
    notification = notify2.Notification(title, message)
    notification.timeout = timeout
    notification.show()
