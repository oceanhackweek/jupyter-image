#syntax=docker/dockerfile:1.3
FROM continuumio/miniconda3:4.12.0@sha256:58b1c7df8d69655ffec017ede784a075e3c2e9feff0fc50ef65300fc75aa45ae

ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/jovyan

ENV CONDA_DIR /srv/conda
ENV CONDA_ENV base

# Output logging faster
ENV PYTHONUNBUFFERED 1
# Don't write bytecode
ENV PYTHONDONTWRITEBYTECODE 1

USER root
RUN adduser --disabled-password --gecos "Default Jupyter user" ${NB_USER} \
    && echo ". ${CONDA_DIR}/etc/profile.d/conda.sh ; conda activate ${CONDA_ENV}" > /etc/profile.d/init_conda.sh \
    && chown -R ${NB_USER}:${NB_USER} /srv

WORKDIR ${HOME}
USER ${USER}

COPY ./conda-linux-64.lock /tmp/

RUN --mount=type=cache,id=ohw_py,target=/opt/conda/pkgs,uid=${NB_UID},gid=${NB_UID} \
    conda install --name ${CONDA_ENV} --file /tmp/conda-linux-64.lock && \
    # micromamba install --name ${CONDA_ENV} --file environment.yml && \
    find -name '*.a' -delete && \
    # rm -rf /opt/conda/conda-meta && \
    rm -rf ${CONDA_DIR}/include && \
    find -name '__pycache__' -type d -exec rm -rf '{}' '+'

COPY CONDARC ./.condarc
COPY --chown=${NB_USER} entrypoint.sh /opt/entrypoint.sh

# USER root
# RUN chown -R jovyan ${CONDA_DIR}
USER ${NB_USER}

ENTRYPOINT [ "/opt/entrypoint.sh" ]
