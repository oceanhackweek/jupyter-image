#syntax=docker/dockerfile:1.17
FROM ghcr.io/prefix-dev/pixi:0.51.0-jammy@sha256:337fedcc9810f2c5c36b3ed3b47e7df21cf0a803901c27eabe4dd92e0b2f4fab

ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/jovyan

ENV PIXI_DIR /home

# Output logging faster
ENV PYTHONUNBUFFERED 1

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
