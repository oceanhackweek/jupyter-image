"""Landing page served at ``<base_url>streamlit/`` in the OHW python image.

jupyter-server-proxy launches one fixed command per named route, and streamlit has no
file browser of its own, so the JupyterLab launcher tile can't open a participant's app
directly. It opens this page instead, which shows how to serve your own script through
the proxy with the paths filled in for the server it's running on.
"""

import os

import streamlit as st

PORT = 8501

# Set by the hub spawner, e.g. "/user/jovyan/". Plain `jupyter lab` serves from "/".
PREFIX = os.environ.get("JUPYTERHUB_SERVICE_PREFIX", "/")
if not PREFIX.endswith("/"):
    PREFIX += "/"
PROXY_PATH = f"{PREFIX}proxy/{PORT}"

st.set_page_config(page_title="Streamlit on OceanHackWeek", page_icon="🌊")

st.title("🌊 Streamlit is ready")
st.write(
    "You're looking at the placeholder app behind the launcher tile. To view an app of "
    "your own, run it from a terminal and open it through the same proxy."
)

st.subheader("1. Serve your app")
st.code(
    "streamlit run app.py \\\n"
    f"  --server.port={PORT} \\\n"
    "  --server.address=127.0.0.1 \\\n"
    "  --server.headless=true",
    language="bash",
)

st.subheader("2. Open it")
st.write(
    f"On this same server, browse to `{PROXY_PATH}/` — the trailing slash matters."
)

st.info(
    f"`/proxy/{PORT}/` strips its own prefix before forwarding, so streamlit needs no "
    "`--server.baseUrlPath`. If you use the prefix-preserving "
    f"`/proxy/absolute/{PORT}/` route instead, pass "
    f"`--server.baseUrlPath={PREFIX}proxy/absolute/{PORT}` to match it — mismatch "
    "the two and the page loads but stays blank. Pick another port if 8501 is taken."
)
