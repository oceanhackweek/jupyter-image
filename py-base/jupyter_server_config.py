"""Jupyter Server config baked into the OHW python image.

marimo-jupyter-extension auto-detects ``--host ::1`` when getaddrinfo reports IPv6
first, which it does in this container. jupyter-server-proxy's readiness probe
reaches localhost over IPv4, so it never sees a marimo bound only to ``[::1]`` and
every ``/marimo/*`` request 500s after the 60s timeout. Pin the bind address to IPv4.
"""

import sys
from pathlib import Path

c = get_config()  # noqa: F821

# The actual fix: never let the ::1 auto-detection win.
c.MarimoProxyConfig.host = "127.0.0.1"

# Don't depend on PATH activation to locate marimo, since the hub spawner may not go
# through /srv/shell-hook.sh. Falls back to the extension's own PATH search.
_marimo = Path(sys.prefix) / "bin" / "marimo"
if _marimo.exists():
    c.MarimoProxyConfig.marimo_path = str(_marimo)

# Skip marimo's PyPI version check on every spawn.
c.MarimoProxyConfig.skip_update_check = True
