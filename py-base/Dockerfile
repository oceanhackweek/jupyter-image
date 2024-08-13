#syntax=docker/dockerfile:1.7
FROM ghcr.io/prefix-dev/pixi:0.26.1-jammy@sha256:45d86bb788aaa24d215eff57712f250329486ca8f442b91959bc9ce7ce6e053c

ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/jovyan

ENV PIXI_DIR /srv/pixi_env

# Output logging faster
ENV PYTHONUNBUFFERED 1

USER root
RUN adduser --disabled-password --gecos "Default Jupyter user" ${NB_USER} \
    && chown -R ${NB_USER}:${NB_USER} /srv \
    && mkdir -p ${PIXI_DIR} \
    && chown -R ${NB_USER}:${NB_USER} ${PIXI_DIR}


WORKDIR ${PIXI_DIR}
USER ${NB_USER}

COPY ./pixi.toml ./pixi.lock ${PIXI_DIR}/

RUN --mount=type=cache,id=ohw_py,target=/home/jovyan/.cache/rattler/cache,uid=${NB_UID},gid=${NB_UID} \
    pixi install --frozen -e default

RUN pixi shell-hook --frozen -e default > /srv/shell-hook.sh \
    && echo 'exec "$@"' >> /srv/shell-hook.sh

ENTRYPOINT ["/bin/bash", "/srv/shell-hook.sh"]

WORKDIR ${HOME}
