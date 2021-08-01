#syntax=docker/dockerfile:1.2
# Most of the stuff here is from:
# https://github.com/2i2c-org/pilot-hubs/tree/master/images/user
# and
# https://uwekorn.com/2021/03/03/deploying-conda-environments-in-docker-cheatsheet.html

FROM buildpack-deps:focal-scm

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
ENV NB_USER jovyan
ENV NB_UID 1000
ENV SHELL /bin/bash

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

RUN adduser --disabled-password --gecos "Default Jupyter user" ${NB_USER} \
    && echo ". ${CONDA_DIR}/etc/profile.d/conda.sh ; conda activate ${CONDA_ENV}" > /etc/profile.d/init_conda.sh \
    && chown -R ${NB_USER}:${NB_USER} /srv

# Create user owned R libs dir
# This lets users temporarily install packages
RUN mkdir -p ${R_LIBS_USER} && chown ${NB_USER}:${NB_USER} ${R_LIBS_USER}

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
ENV RSTUDIO_URL https://download2.rstudio.org/server/bionic/amd64/rstudio-server-1.2.5042-amd64.deb
RUN curl --silent --location --fail ${RSTUDIO_URL} > /tmp/rstudio.deb && \
    dpkg -i /tmp/rstudio.deb && \
    rm /tmp/rstudio.deb

WORKDIR /home/jovyan

COPY install-miniforge.bash /tmp/install-miniforge.bash
RUN /tmp/install-miniforge.bash

USER ${NB_USER}

COPY --chown=jovyan:jovyan conda-linux-64.lock /tmp/conda-linux-64.lock
RUN --mount=type=cache,target=${CONDA_DIR}/pkgs \
    conda install --name ${CONDA_ENV} --file /tmp/conda-linux-64.lock && \
    find -name '*.a' -delete && \
    # rm -rf /opt/conda/conda-meta && \
    rm -rf ${CONDA_DIR}/include && \
    rm ${CONDA_DIR}/lib/libpython3.9.so.1.0 && \
    find -name '__pycache__' -type d -exec rm -rf '{}' '+'

# Install BigelowLab dev R libs
# RUN installGithub.R BigelowLab/rasf BigelowLab/ohwobpg  # not working on GH but works locally :-/
RUN Rscript -e "remotes::install_github('BigelowLab/ohwobpg', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_github('BigelowLab/rasf', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)"

# TEST
RUN python -c "import cartopy; import cartopy.crs; print(cartopy.__version__)"

COPY CONDARC ./.condarc
