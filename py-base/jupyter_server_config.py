"""Jupyter Server config baked into the OHW python image.

Wires up the two proxied web apps the image ships: marimo, through
marimo-jupyter-extension, and streamlit, through jupyter-server-proxy directly.

Both hit the same trap. jupyter-server-proxy's readiness probe reaches localhost over
IPv4, so a server that auto-detects ``::1`` -- which getaddrinfo reports first in this
container -- is never seen as ready, and every proxied request 500s after the 60s
timeout. Pin both to IPv4.
"""

import sys
from pathlib import Path

c = get_config()  # noqa: F821

# --- marimo ---------------------------------------------------------------------

# The actual fix: never let the ::1 auto-detection win.
c.MarimoProxyConfig.host = "127.0.0.1"

# Don't depend on PATH activation to locate marimo, since the hub spawner may not go
# through /srv/shell-hook.sh. Falls back to the extension's own PATH search.
_marimo = Path(sys.prefix) / "bin" / "marimo"
if _marimo.exists():
    c.MarimoProxyConfig.marimo_path = str(_marimo)

# Skip marimo's PyPI version check on every spawn.
c.MarimoProxyConfig.skip_update_check = True

# --- streamlit ------------------------------------------------------------------

# streamlit has no notebook-style file browser, and jupyter-server-proxy launches one
# fixed command per named route, so the launcher tile can't open a participant's app
# directly. It opens a welcome app that documents how to serve your own script over
# /proxy/absolute/<port>/ instead.
_streamlit = Path(sys.prefix) / "bin" / "streamlit"
_welcome = Path("/opt/ohw/streamlit_welcome.py")
if _streamlit.exists() and _welcome.exists():
    c.ServerProxy.servers = {
        "streamlit": {
            "command": [
                str(_streamlit),
                "run",
                str(_welcome),
                "--server.port={port}",
                # Same IPv4 pin as marimo above.
                "--server.address=127.0.0.1",
                "--server.headless=true",
                # absolute_url leaves the /streamlit prefix on proxied requests, so
                # streamlit has to know it to build its asset and websocket URLs.
                # base_url is the server's own prefix: "/" under plain `jupyter lab`,
                # "/user/<name>/" under the hub.
                "--server.baseUrlPath={base_url}streamlit",
                "--browser.gatherUsageStats=false",
            ],
            "absolute_url": True,
            "timeout": 60,
            "launcher_entry": {"title": "Streamlit"},
        },
    }

# --- launcher branding ----------------------------------------------------------

# Registers the /custom/(.*) route and makes the page template link custom/custom.css,
# which carries the OceanHackWeek banner at the top of the launcher. Applies under
# `jupyterhub-singleuser` as well as `jupyter lab`: jupyterlab is a jupyter_server
# ExtensionApp, and ExtensionApp._link_jupyter_server_extension() calls
# update_config(serverapp.config), which carries this file's LabApp section into
# LabApp's traits. See py-base/custom.css for where the file has to live.
c.LabApp.custom_css = True
