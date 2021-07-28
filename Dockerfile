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

ENV CONDA_DIR /opt/conda
ENV R_LIBS_USER /opt/r

# Explicitly add littler to PATH
# See https://github.com/conda-forge/r-littler-feedstock/issues/6
ENV PATH ${CONDA_DIR}/lib/R/library/littler/bin:${CONDA_DIR}/bin:$PATH

RUN adduser --disabled-password --gecos "Default Jupyter user" ${NB_USER}

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
        locales > /dev/null

RUN echo "${LC_ALL} UTF-8" > /etc/locale.gen && \
    locale-gen

WORKDIR /home/jovyan

COPY install-miniforge.bash /tmp/install-miniforge.bash
RUN /tmp/install-miniforge.bash

COPY conda-linux-64.lock /tmp/conda-linux-64.lock
RUN conda install --name base --file /tmp/conda-linux-64.lock

# Needed by RStudio
RUN apt-get update -qq --yes && \
    apt-get install --yes --no-install-recommends -qq \
        psmisc \
        sudo \
        libapparmor1 \
        lsb-release \
        libclang-dev  > /dev/null

# Set path where R packages are installed
# Download and install rstudio manually
# Newer one has bug that doesn't work with jupyter-rsession-proxy
ENV RSTUDIO_URL https://download2.rstudio.org/server/bionic/amd64/rstudio-server-1.2.5042-amd64.deb
RUN curl --silent --location --fail ${RSTUDIO_URL} > /tmp/rstudio.deb && \
    dpkg -i /tmp/rstudio.deb && \
    rm /tmp/rstudio.deb

USER ${NB_USER}

# Install BigelowLab dev R libs
# RUN installGithub.R BigelowLab/rasf BigelowLab/ohwobpg  # not working on GH but works locally :-/
RUN Rscript -e "remotes::install_github('BigelowLab/ohwobpg', dependencies = NA, upgrade_dependencies = FALSE)" && \
    Rscript -e "remotes::install_github('BigelowLab/rasf', dependencies = NA, upgrade_dependencies = FALSE)"

# TEST
RUN python -c "import cartopy; import cartopy.crs; print(cartopy.__version__)"
