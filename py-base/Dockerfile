#syntax=docker/dockerfile:1.7
FROM ghcr.io/prefix-dev/pixi:0.26.1-jammy@sha256:45d86bb788aaa24d215eff57712f250329486ca8f442b91959bc9ce7ce6e053c

ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/jovyan

ENV CONDA_DIR /srv/conda
ENV CONDA_ENV base

# Output logging faster
ENV PYTHONUNBUFFERED 1

USER root
RUN adduser --disabled-password --gecos "Default Jupyter user" ${NB_USER} \
    # && echo ". ${CONDA_DIR}/etc/profile.d/conda.sh ; conda activate ${CONDA_ENV}" > /etc/profile.d/init_conda.sh \
    && chown -R ${NB_USER}:${NB_USER} /srv

WORKDIR ${HOME}
USER ${NB_USER}

COPY ./pixi.toml ./pixi.lock ${HOME}

RUN --mount=type=cache,id=ohw_py,target=/home/jovyan/.cache/rattler/cache,uid=${NB_UID},gid=${NB_UID} \
    pixi install --frozen -e default

RUN pixi shell-hook --frozen -e default > /srv/shell-hook.sh \
    && echo 'exec "$@"' >> /srv/shell-hook.sh

ENTRYPOINT ["/bin/bash", "/srv/shell-hook.sh"]
