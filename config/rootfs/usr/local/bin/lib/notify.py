from notify2 import Notification, init

init("CWRScript")


def notify(title: str, message: str, timeout: int = 2000) -> None:
    notification: Notification = Notification(title, message)
    notification.timeout = timeout
    notification.show()
