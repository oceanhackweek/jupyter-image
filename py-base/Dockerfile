#syntax=docker/dockerfile:1.26
FROM ghcr.io/prefix-dev/pixi:0.76.2-jammy@sha256:92a49c557742c9dbfd73d64a7887ea387bad824421265ec083c79da8f8f9d598

ENV NB_USER=jovyan
ENV NB_UID=1000
ENV HOME=/home/jovyan

ENV PIXI_DIR=/home

# Output logging faster
ENV PYTHONUNBUFFERED=1

# Increase marimo output limit for OHW25 proj Riptide Remix
ENV MARIMO_OUTPUT_MAX_BYTES=20_000_000

USER root
RUN adduser --disabled-password --gecos "Default Jupyter user" ${NB_USER} \
    && chown -R ${NB_USER}:${NB_USER} /srv \
    && mkdir -p ${PIXI_DIR} \
    && chown -R ${NB_USER}:${NB_USER} ${PIXI_DIR}


# less is the pager git, gh, and man shell out to; without it `git log` and friends
# dump straight to the terminal. The pixi jammy base doesn't ship it.
RUN apt-get update \
    && apt-get install --no-install-recommends -y ca-certificates=20260601~22.04.1 curl=7.81.0-1ubuntu1.26 gnupg=2.2.27-3ubuntu2.5 less=590-1ubuntu0.22.04.3 \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN install -d -m 0755 /etc/apt/keyrings \
    && curl -fsSL https://downloads.claude.ai/keys/claude-code.asc -o /etc/apt/keyrings/claude-code.asc \
    && echo "deb [signed-by=/etc/apt/keyrings/claude-code.asc] https://downloads.claude.ai/claude-code/apt/stable stable main" \
       > /etc/apt/sources.list.d/claude-code.list \
    && apt-get update \
    && apt-get install --no-install-recommends -y claude-code=2.1.228-1 \
    && rm -rf /var/lib/apt/lists/*

# Pins the marimo and streamlit bind addresses to IPv4 so jupyter-server-proxy's
# readiness probe can reach them, and registers the proxied /streamlit/ route. Applies
# to `jupyter lab` and `jupyterhub-singleuser` alike, since /etc/jupyter is on the
# Jupyter config search path.
COPY ./jupyter_server_config.py /etc/jupyter/jupyter_server_config.py

# Placeholder app behind the /streamlit/ launcher tile.
COPY ./streamlit_welcome.py /opt/ohw/streamlit_welcome.py

WORKDIR ${PIXI_DIR}
USER ${NB_USER}

COPY ./pixi.toml ./pixi.lock ${PIXI_DIR}/

RUN --mount=type=cache,id=ohw_py,target=${HOME}/.cache/rattler/cache,uid=${NB_UID},gid=${NB_UID} \
    pixi install --frozen -e default

RUN pixi shell-hook --frozen -e default > /srv/shell-hook.sh \
    && echo 'exec "$@"' >> /srv/shell-hook.sh

# --- OceanHackWeek launcher branding --------------------------------------------
# Kept below the pixi layers: OHW_IMAGE_TAG changes on every commit, and these two
# layers are cheap to rebuild while `pixi install` is not.
#
# custom.css has to land on ServerApp.static_custom_path. That trait is a plain
# List(Unicode()) with no config=True, so it can't be pointed elsewhere from a config
# file, and neither can ServerApp.config_dir. Its first entry, ~/.jupyter/custom, is
# masked by the home volume the hub mounts over /home/jovyan; the second,
# <jupyter_server package>/static/custom, is baked into the image. /etc/jupyter/custom
# is *not* on that path.
COPY ./custom.css /opt/ohw/custom.css

ARG OHW_IMAGE_TAG=dev
# Exported so the tag is greppable from a terminal and from ci/smoke-test.sh.
ENV OHW_IMAGE_TAG=${OHW_IMAGE_TAG}

# The tag is appended as a second :root block rather than substituted into the first:
# the later declaration wins by cascade, so there's no pattern that can drift and
# silently ship "dev". RUN doesn't go through /srv/shell-hook.sh, so the interpreter is
# named by path; jupyter_server's location is asked for rather than assumed, since it
# contains the python version. The closing grep fails the build if either breaks.
RUN case "${OHW_IMAGE_TAG}" in \
      "" | *[!a-zA-Z0-9._-]*) echo "refusing unsafe OHW_IMAGE_TAG: ${OHW_IMAGE_TAG}" >&2; exit 1 ;; \
    esac \
    && CUSTOM_DIR="$("${PIXI_DIR}/.pixi/envs/default/bin/python" -c 'import jupyter_server, os; print(os.path.join(os.path.dirname(jupyter_server.__file__), "static", "custom"))')" \
    && install -D -m 0644 /opt/ohw/custom.css "${CUSTOM_DIR}/custom.css" \
    && printf ':root { --ohw-image-tag: "%s"; }\n' "${OHW_IMAGE_TAG}" >> "${CUSTOM_DIR}/custom.css" \
    && grep -q -- "--ohw-image-tag: \"${OHW_IMAGE_TAG}\"" "${CUSTOM_DIR}/custom.css"

ENTRYPOINT ["/bin/bash", "/srv/shell-hook.sh"]

WORKDIR ${HOME}
