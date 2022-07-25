#syntax=docker/dockerfile:1.3
FROM mambaorg/micromamba:0.24.0@sha256:653470badb12d800ef925aaade7e22e1a2738e6418ef3abd4ce557411af0d70c

ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/jovyan

ENV CONDA_DIR /srv/conda
ENV CONDA_ENV base

USER root
RUN adduser --disabled-password --gecos "Default Jupyter user" ${NB_USER} \
    && echo ". ${CONDA_DIR}/etc/profile.d/conda.sh ; conda activate ${CONDA_ENV}" > /etc/profile.d/init_conda.sh \
    && chown -R ${NB_USER}:${NB_USER} /srv

WORKDIR ${HOME}
# USER ${NB_USER}
USER ${USER}

COPY ./conda-linux-64.lock /tmp/

RUN --mount=type=cache,id=ohw_py,target=/opt/conda/pkgs,uid=${NB_UID},gid=${NB_UID} \
    micromamba install --name ${CONDA_ENV} --file /tmp/conda-linux-64.lock && \
    # micromamba install --name ${CONDA_ENV} --file environment.yml && \
    find -name '*.a' -delete && \
    # rm -rf /opt/conda/conda-meta && \
    rm -rf ${CONDA_DIR}/include && \
    find -name '__pycache__' -type d -exec rm -rf '{}' '+'

COPY CONDARC ./.condarc

# USER root
# RUN chown -R jovyan ${CONDA_DIR}
USER ${NB_USER}
