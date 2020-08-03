# jupyter-image for OceanhackWeek

Repository for building OceanhackWeek 2020 [JupyterHub](https://jupyter.org/hub) environment (Docker Image) with [GitHub Actions CI](https://help.github.com/en/actions/automating-your-workflow-with-github-actions)

![Action Status](https://github.com/oceanhackweek/jupyter-image/workflows/MasterBuild/badge.svg)
![Docker Pulls](https://img.shields.io/docker/pulls/uwhackweeks/OceanhackWeek)

Docker images publically available here: https://hub.docker.com/repository/docker/uwhackweeks/OceanhackWeek

This repository contains configuration for the standard environment used during the OceanhackWeek 2020.
When you log into the OceanhackWeek JupyterHub you are running a virtual machine with Ubuntu 18.04,
a variety of command line tools like `vim` and `git`,
a `conda` Python/R environment with compatibly package versions,
and JupyterLab extensions such as `ipywidgets` and `ipyleaflet`.
By packaging everything up with Docker we help ensure that code written during the hackweek is reproducible and can be run on different physical hardware today and in the future.