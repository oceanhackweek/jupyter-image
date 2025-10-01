#syntax=docker/dockerfile:1.19
FROM continuumio/miniconda3:24.7.1-0@sha256:f37f8c7db26ae7ec0098df530e96c9cde139026b9faf3914800d1522c47a49b1

ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/${NB_USER}

ENV CONDA_DIR /opt/conda
ENV CONDA_ENV base
ENV R_LIBS_USER /opt/r

# Explicitly add littler to PATH
# See https://github.com/conda-forge/r-littler-feedstock/issues/6
# 11/14/2024: The littler path appears to be solved already
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
    # 11/14/24: should this lib version be udpated?
    libapparmor1 \
    libfmt-dev \
    # 11/14/24: should this lib version be udpated?
    libpq5 \
    libssl-dev \
    lsb-release \
    ca-certificates \
    libclang-dev > /dev/null \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN echo "${LC_ALL} UTF-8" > /etc/locale.gen && \
    locale-gen

# # Set path where R packages are installed
# # Download and install rstudio-server manually
# Get the url at https://posit.co/download/rstudio-server/:
ENV RSTUDIO_URL https://download2.rstudio.org/server/jammy/amd64/rstudio-server-2024.09.1-394-amd64.deb

RUN curl --silent --location --fail ${RSTUDIO_URL} > /tmp/rstudio.deb && \
    dpkg -i /tmp/rstudio.deb && \
    rm /tmp/rstudio.deb

USER ${USER}

WORKDIR ${HOME}

COPY ./conda-linux-64.lock /tmp/

RUN --mount=type=cache,id=ohw_r,target=${CONDA_DIR}/pkgs,uid=${NB_UID},gid=${NB_UID} \
    # https://github.com/jupyterhub/jupyterhub-deploy-docker/issues/91#issuecomment-525563836
    # To avoid libmamba and libarchive channel conflicts, make sure conda-forge is the only channel
    # https://github.com/conda/conda-libmamba-solver/issues/283#issuecomment-1949560105
    conda config --add channels conda-forge && \
    conda update --all && \
    conda install --name ${CONDA_ENV} --file /tmp/conda-linux-64.lock && \
    find -name '*.a' -delete && \
    # rm -rf /opt/conda/conda-meta && \
    rm -rf ${CONDA_DIR}/include && \
    find -name '__pycache__' -type d -exec rm -rf '{}' '+'

ARG MAMBA_DOCKERFILE_ACTIVATE=1

# Install R libs from CRAN and GitHub
RUN \
    # -- Dependencies to the target packages, not already installed via the conda environment
    #    Install dependencies before "target" packages, either in the conda environment or here
    Rscript -e "remotes::install_cran('PBSmapping', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    # -- Target packages
    Rscript -e "remotes::install_cran('plot.matrix', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_cran('isdparser', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_cran('geonames', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_cran('readHAC', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_cran('rnoaa', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_cran('greybox', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_cran('sfnetworks', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_cran('smooth', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_github('BigelowLab/ohwobpg', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_github('BigelowLab/rasf', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_github('BigelowLab/xyzt', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_github('BigelowLab/ghrsst', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_github('BigelowLab/bsw', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_github('BigelowLab/ersst', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_github('BigelowLab/hycom', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_github('hadley/emo', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_github('hvillalo/echogram', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_github('hvillalo/periods', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_github('hvillalo/satin', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_github('JorGarMol/VoCC', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)"

COPY CONDARC ./.condarc
COPY Rprofile.site ${CONDA_DIR}/lib/R/etc/

ENV PATH /usr/lib/rstudio-server/bin/:${PATH}

ENV LD_LIBRARY_PATH=${CONDA_DIR}/lib

# USER root
# RUN chown -R jovyan ${CONDA_DIR}
# https://github.com/oceanhackweek/jupyter-image/pull/97#issuecomment-2488105625
RUN chown -R ${NB_USER} ${HOME}/.cache
USER ${NB_USER}
