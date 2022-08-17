#syntax=docker/dockerfile:1.3
FROM continuumio/miniconda3:4.12.0@sha256:58b1c7df8d69655ffec017ede784a075e3c2e9feff0fc50ef65300fc75aa45ae

ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/jovyan

ENV CONDA_DIR /opt/conda
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
RUN --mount=type=cache,id=ohw_r_apt,target=/var/cache/apt \
    apt-get update -qq --yes > /dev/null && \
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
    libpq5 \
    lsb-release \
    libclang-dev > /dev/null && \
    rm -rf /var/lib/apt/lists/*

RUN echo "${LC_ALL} UTF-8" > /etc/locale.gen && \
    locale-gen

# # Set path where R packages are installed
# # Download and install rstudio manually
# # Newer one has bug that doesn't work with jupyter-rsession-proxy
ENV RSTUDIO_URL https://download2.rstudio.org/server/bionic/amd64/rstudio-server-2022.07.1-554-amd64.deb
# ENV RSTUDIO_URL https://download2.rstudio.org/server/bionic/amd64/rstudio-server-1.2.5042-amd64.deb
RUN curl --silent --location --fail ${RSTUDIO_URL} > /tmp/rstudio.deb && \
    dpkg -i /tmp/rstudio.deb && \
    rm /tmp/rstudio.deb

USER ${USER}

WORKDIR ${HOME}
USER ${USER}

COPY ./conda-linux-64.lock /tmp/

RUN --mount=type=cache,id=ohw_r,target=/opt/conda/pkgs,uid=${NB_UID},gid=${NB_UID} \
    conda install --name ${CONDA_ENV} --file /tmp/conda-linux-64.lock && \
    # micromamba install --name ${CONDA_ENV} --file environment.yml && \
    find -name '*.a' -delete && \
    # rm -rf /opt/conda/conda-meta && \
    rm -rf ${CONDA_DIR}/include && \
    find -name '__pycache__' -type d -exec rm -rf '{}' '+'

ARG MAMBA_DOCKERFILE_ACTIVATE=1

# Install BigelowLab dev R libs
# RUN installGithub.R BigelowLab/rasf BigelowLab/ohwobpg  # not working on GH but works locally :-/
RUN Rscript -e "remotes::install_cran('assertthat', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_cran('ggspatial', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_cran('plot.matrix', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_cran('isdparser', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_cran('geonames', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_cran('rnoaa', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_cran('sfnetworks', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_github('hadley/emo', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_github('BigelowLab/ohwobpg', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_github('BigelowLab/rasf', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_github('BigelowLab/xyzt', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_github('BigelowLab/ghrsst', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_github('BigelowLab/bsw', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_github('BigelowLab/ersst', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_github('BigelowLab/hycom', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_github('kwstat/pals', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)"

COPY CONDARC ./.condarc
COPY Rprofile.site /opt/conda/lib/R/etc/

ENV PATH /usr/lib/rstudio-server/bin/:${PATH}

ENV LD_LIBRARY_PATH=${CONDA_DIR}/lib

# USER root
# RUN chown -R jovyan ${CONDA_DIR}
USER ${NB_USER}
