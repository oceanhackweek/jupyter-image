#syntax=docker/dockerfile:1.3
FROM mambaorg/micromamba:0.24.0@sha256:653470badb12d800ef925aaade7e22e1a2738e6418ef3abd4ce557411af0d70c

ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/jovyan

ENV CONDA_DIR /srv/conda
ENV CONDA_ENV base
ENV R_LIBS_USER /opt/r

# Explicitly add littler to PATH
# See https://github.com/conda-forge/r-littler-feedstock/issues/6
ENV PATH ${CONDA_DIR}/lib/R/library/littler/bin:${CONDA_DIR}/bin:$PATH

# Output logging faster
ENV PYTHONUNBUFFERED 1
# Don't write bytecode
ENV PYTHONDONTWRITEBYTECODE 1

USER root
RUN adduser --disabled-password --gecos "Default Jupyter user" ${NB_USER} \
    && echo ". ${CONDA_DIR}/etc/profile.d/conda.sh ; conda activate ${CONDA_ENV}" > /etc/profile.d/init_conda.sh \
    && chown -R ${NB_USER}:${NB_USER} /srv

# Install these without 'recommended' packages to keep image smaller.
# Useful utils that folks sort of take for granted
RUN apt-get update -qq --yes > /dev/null && \
    apt-get install --yes --no-install-recommends -qq \
    curl \
    git \
    less \
    tar \
    tzdata \
    vim \
    wget \
    locales \
    psmisc \
    sudo \
    libapparmor1 \
    lsb-release \
    libclang-dev > /dev/null

RUN echo "${LC_ALL} UTF-8" > /etc/locale.gen && \
    locale-gen

# Set path where R packages are installed
# Download and install rstudio manually
# Newer one has bug that doesn't work with jupyter-rsession-proxy
ENV RSTUDIO_URL https://download2.rstudio.org/server/bionic/amd64/rstudio-server-2022.07.1-554-amd64.deb
RUN curl --silent --location --fail ${RSTUDIO_URL} > /tmp/rstudio.deb && \
    dpkg -i /tmp/rstudio.deb && \
    rm /tmp/rstudio.deb

USER ${USER}

WORKDIR ${HOME}
USER ${USER}

COPY ./conda-linux-64.lock /tmp/

RUN --mount=type=cache,id=ohw_r,target=/opt/conda/pkgs,uid=${NB_UID},gid=${NB_UID} \
    micromamba install --name ${CONDA_ENV} --file /tmp/conda-linux-64.lock && \
    # micromamba install --name ${CONDA_ENV} --file environment.yml && \
    find -name '*.a' -delete && \
    # rm -rf /opt/conda/conda-meta && \
    rm -rf ${CONDA_DIR}/include && \
    find -name '__pycache__' -type d -exec rm -rf '{}' '+'

ARG MAMBA_DOCKERFILE_ACTIVATE=1

# Install BigelowLab dev R libs
# RUN installGithub.R BigelowLab/rasf BigelowLab/ohwobpg  # not working on GH but works locally :-/
RUN Rscript -e "remotes::install_github('BigelowLab/ohwobpg', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_github('BigelowLab/rasf', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)"


COPY CONDARC ./.condarc

# USER root
# RUN chown -R jovyan ${CONDA_DIR}
USER ${NB_USER}
