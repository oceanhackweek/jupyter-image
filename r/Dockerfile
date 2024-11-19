FROM ghcr.io/rocker-org/binder:4.4.1@sha256:0206f61770c76c3744ecd898c273a5778ad3dd18d1b30e396f90f00dec42d787

ENV NB_UID=1000

RUN --mount=type=cache,id=ohw_r,target=/tmp/downloaded_packages,uid=${NB_UID},gid=${NB_UID} \
    install2.r -e \
    assertthat \
    forecast \
    ggspatial \
    plot.matrix \
    isdparser \
    geonames \
    readHAC \
    # rnoaa \ not available for this version of R
    greybox \
    sfnetworks \
    smooth \
    akima \
    ape \
    automap \
    biomod2 \
    bitops \
    caret \
    # catools \ not available for this version of R
    checkmate \
    commonmark \
    cowplot \
    crul \
    # dbi \
    # devtools \
    # dichromat \
    dismo \
    # doparallel \ not available for this version of R
    # dplyr \
    earth \
    rerddap \
    foreach \
    # foreign \
    # fracdiff \
    gbm >=2.1.3 \
    geometry \
    # geosphere \
    # ggplot2 \
    glmnet \
    # gridextra \ not available for this version of R
    gsw \
    hexbin \
    httpcache \
    # httr \
    # igraph \
    # irkernel \
    # jsonlite \
    # knitr \
    # lattice \
    # leaflet \
    # littler \
    # lmtest \
    # lpsolve \ not available for this version of R
    # lubridate \
    mmand \
    # mapdata \
    mapedit \
    # maps \
    # maptools \ not available for this version of R
    marmap \
    markdown \
    # mass \
    mda \
    # metr \ not available for this version of R
    # ncdf4 \
    # nnet \
    # nloptr \
    oce \
    ocedata \
    rosm \
    palmerpenguins \
    patchwork \
    PCICt \
    plotly \
    # proc >=1.15.0 \ not available for this version of R
    # ps>=1.3.4 \
    # purrr \
    # r.utils \ not available for this version of R
    # randomforest \ not available for this version of R
    # rann \ not available for this version of R
    # raster >=1.4.3 \
    # rastervis \ not available for this version of R
    # readr \
    # remotes \
    reshape \
    # rgdal >=1.5 \ not available for this version of R
    # rgeos \ not available for this version of R
    rlang \
    # rmarkdown \
    rnaturalearth \
    rnaturalearthdata \
    robis \
    # rpart \
    # rsqlite \
    rstackdeque \
    rvest \
    # s2 \
    # scales \
    # sf >=0.9_5 \
    # sp \
    # stars \
    # terra \
    # tibble \
    # tidyr \
    # tidygraph \
    # tidyverse \
    tiff \
    # tmap \
    # tmaptools \
    # tseries \
    tsibble \
    tzdb \
    udunits2 \
    # urca \
    vegan \
    viridis \
    # vroom \
    wdpar \
    xaringan
    # xml2 \
    # xts \

RUN Rscript -e "remotes::install_github('BigelowLab/ohwobpg', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
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
    Rscript -e "remotes::install_github('kwstat/pals', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)" && \
    Rscript -e "remotes::install_github('JorGarMol/VoCC', dependencies=FALSE, upgrade_dependencies=FALSE, upgrade=FALSE)"