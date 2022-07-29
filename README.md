# jupyter-image for OceanhackWeek

Repository for building OceanhackWeek 2022
[JupyterHub](https://jupyter.org/hub) environments (Docker Images) with
[GitHub Actions CI](https://help.github.com/en/actions/automating-your-workflow-with-github-actions)

Docker images publicly [available here](https://github.com/orgs/oceanhackweek/packages?repo_name=jupyter-image). `jupyter-image` is the 2021 image, while `python` and `r` are for their matching profiles on the hub.

This repository contains configuration for the standard environment used during the OceanhackWeek 2021.
When you log into the OceanhackWeek JupyterHub you are running a virtual machine with Ubuntu 22.04,
a variety of command line tools like `vim` and `git`,
a `conda` Python/R environment with compatibly package versions,
and JupyterLab extensions such as `ipywidgets` and `ipyleaflet`.
By packaging everything up with Docker we help ensure that code written during the hackweek is reproducible and can be run on different physical hardware today and in the future.