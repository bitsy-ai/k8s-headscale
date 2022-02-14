import base64


def b64decode(x):
    return base64.b64decode(x)


def b64encode(x):
    return base64.b64encode(x.encode('utf-8')).decode('utf-8')
