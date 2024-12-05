#syntax=docker/dockerfile:1.7
FROM ghcr.io/prefix-dev/pixi:0.38.0-jammy@sha256:42d9530a15076a09ba3f64da4d163fdcfe30b728a5221603e2e0a9e9b4d0fae3

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
