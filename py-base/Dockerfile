#syntax=docker/dockerfile:1.26
FROM ghcr.io/prefix-dev/pixi:0.76.2-jammy@sha256:92a49c557742c9dbfd73d64a7887ea387bad824421265ec083c79da8f8f9d598

ENV NB_USER=jovyan
ENV NB_UID=1000
ENV HOME=/home/jovyan

ENV PIXI_DIR=/home
# Enable Marimo locally, should be overridden in production
ENV JUPYTERHUB_SERVICE_PREFIX=/

# Output logging faster
ENV PYTHONUNBUFFERED=1

# Increase marimo output limit for OHW25 proj Riptide Remix
ENV MARIMO_OUTPUT_MAX_BYTES=20_000_000

USER root
RUN adduser --disabled-password --gecos "Default Jupyter user" ${NB_USER} \
    && chown -R ${NB_USER}:${NB_USER} /srv \
    && mkdir -p ${PIXI_DIR} \
    && chown -R ${NB_USER}:${NB_USER} ${PIXI_DIR}


RUN apt-get update \
    && apt-get install --no-install-recommends -y ca-certificates=20260601~22.04.1 curl=7.81.0-1ubuntu1.26 \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR ${PIXI_DIR}
USER ${NB_USER}

# Install Claude Code
# https://github.com/hadolint/hadolint/wiki/DL4006
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl -fsSL https://claude.ai/install.sh | bash -s stable
ENV PATH="${HOME}/.local/bin:${PATH}"

COPY ./pixi.toml ./pixi.lock ${PIXI_DIR}/

RUN --mount=type=cache,id=ohw_py,target=${HOME}/.cache/rattler/cache,uid=${NB_UID},gid=${NB_UID} \
    pixi install --frozen -e default

RUN pixi shell-hook --frozen -e default > /srv/shell-hook.sh \
    && echo 'exec "$@"' >> /srv/shell-hook.sh

ENTRYPOINT ["/bin/bash", "/srv/shell-hook.sh"]

WORKDIR ${HOME}
