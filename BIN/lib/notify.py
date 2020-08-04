import notify2

notify2.init("CWRScript")


def notify(title, message, timeout=2000):
    notification = notify2.Notification(title, message)
    notification.timeout = timeout
    notification.show()
