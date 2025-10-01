#syntax=docker/dockerfile:1.19
FROM ghcr.io/prefix-dev/pixi:0.53.0-jammy@sha256:3a43a1c0663c8b638836162518ba76a465ff7a0296b00f99e61af88bcf442c5a

ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/jovyan

ENV PIXI_DIR /home
# Enable Marimo locally, should be overridden in production
ENV JUPYTERHUB_SERVICE_PREFIX / 

# Output logging faster
ENV PYTHONUNBUFFERED 1

# Increase marimo output limit for OHW25 proj Riptide Remix
ENV MARIMO_OUTPUT_MAX_BYTES 20_000_000

USER root
RUN adduser --disabled-password --gecos "Default Jupyter user" ${NB_USER} \
    && chown -R ${NB_USER}:${NB_USER} /srv \
    && mkdir -p ${PIXI_DIR} \
    && chown -R ${NB_USER}:${NB_USER} ${PIXI_DIR}


RUN apt-get update \
    && apt-get install ca-certificates -y \
    && update-ca-certificates


WORKDIR ${PIXI_DIR}
USER ${NB_USER}

COPY ./pixi.toml ./pixi.lock ${PIXI_DIR}/

RUN --mount=type=cache,id=ohw_py,target=${HOME}/.cache/rattler/cache,uid=${NB_UID},gid=${NB_UID} \
    pixi install --frozen -e default

RUN pixi shell-hook --frozen -e default > /srv/shell-hook.sh \
    && echo 'exec "$@"' >> /srv/shell-hook.sh

ENTRYPOINT ["/bin/bash", "/srv/shell-hook.sh"]

WORKDIR ${HOME}
