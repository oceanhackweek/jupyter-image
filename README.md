# jupyter-image for OceanhackWeek

Repository for building OceanhackWeek 2023
[JupyterHub](https://jupyter.org/hub) environments (Docker Images) with
[GitHub Actions CI](https://help.github.com/en/actions/automating-your-workflow-with-github-actions)

Docker images publicly [available here](https://github.com/orgs/oceanhackweek/packages?repo_name=jupyter-image). `jupyter-image` is the 2021 image, while `python` and `r` are for their matching profiles on the hub.

This repository contains configuration for the standard environment used during the OceanhackWeek 2023.
When you log into the OceanhackWeek JupyterHub you are running a virtual machine with Ubuntu 22.04,
a variety of command line tools like `vim` and `git`,
a `conda` Python/R environment with compatibly package versions,
and JupyterLab extensions such as `ipywidgets` and `ipyleaflet`.
By packaging everything up with Docker we help ensure that code written during the hackweek is reproducible and can be run on different physical hardware today and in the future.

## Development commands

There are a handful of helpful `make` commands for building and testing images.

- `py-lock` - Generate a new Python lockfile.
- `py-build` - Build Python Docker container (should regenerate lockfile if `environment.yml` was changed).
- `py-lab` - Launch JupyterLab for Python image. Watch the terminal output for a `127.0.0.1:8080/...` link with the access token.
- `r-lock` - Generate a new R lockfile.
- `r-build` - Build R Docker container (should regenerate lockfile if `environment.yml` was changed).
- `r-lab` - Launch JupyterLab for R image. Watch the terminal output for a `127.0.0.1:8080/...` link with the access token. Once in JupyterLab, you should be able to launch RStudio.

## Testing user-generated environments

Both images use [`nb_conda_kernels` ](https://github.com/Anaconda-Platform/nb_conda_kernels) which allows our users to create their own Conda environments. 

This makes it so that we don't have to package everything into the images to start with.

To test that environments can be created, launch JupyterLab in one of the images.

- `conda create -n <env-name> <requirements>`, and make sure one of the requirements is a Jupyter kernel, like `ipykernel`.
- Try `conda activate <env-name>` and seeing if it's different than the base environment.
- The JupyerLab new notebook/console creation screen should now show options for `<env-name>`. This can sometimes take a few minutes before `nb_conda_kernels` sees it.
