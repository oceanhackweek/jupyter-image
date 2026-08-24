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

- `py-build` - Build Python Docker container (should regenerate lockfile if `environment.yml` was changed).
- `py-lab` - Launch JupyterLab for Python image. Watch the terminal output for a `127.0.0.1:8080/...` link with the access token.
- `r-lock` - Generate a new R lockfile.
- `r-build` - Build R Docker container (should regenerate lockfile if `environment.yml` was changed).
- `r-lab` - Launch JupyterLab for R image. Watch the terminal output for a `127.0.0.1:8080/...` link with the access token. Once in JupyterLab, you should be able to launch RStudio.

## Streamlit apps

The Python image ships `streamlit`, served through
[jupyter-server-proxy](https://jupyter-server-proxy.readthedocs.io/) so that apps are
reached over the single-user server's own URL. Nothing has to be configured on the hub
itself, and no extra ports are exposed.

The **Streamlit** tile in the JupyterLab launcher opens `py-base/streamlit_welcome.py`,
a placeholder app. jupyter-server-proxy launches one fixed command per named route, so
the tile can't open a participant's own app — to view one, run it from a terminal and
open it through the proxy:

```bash
streamlit run app.py --server.port=8501 --server.address=127.0.0.1 --server.headless=true
```

Then browse to `/user/<name>/proxy/8501/`, trailing slash included.

`/proxy/<port>/` strips its own prefix before forwarding, which is why no
`--server.baseUrlPath` is needed. The rule is that streamlit's idea of its base path
has to match the route: pass `--server.baseUrlPath=/user/<name>/proxy/absolute/8501` if
you use the prefix-preserving `/proxy/absolute/8501/` route instead. Mismatch the two
and the page loads but stays blank, because streamlit's asset URLs 404.

`--server.address=127.0.0.1` keeps streamlit off IPv6-only binds, which
jupyter-server-proxy's readiness probe can't reach.

Streamlit comes from PyPI rather than conda-forge: conda-forge's `pydeck` constrains
`ipywidgets <8`, which can't be satisfied alongside the `ipywidgets` 8 the tutorials
need. See the comment in `py-base/pixi.toml`.

## Launcher branding

The Python image draws an OceanHackWeek banner across the top of the JupyterLab
launcher, above the tiles, reading the wordmark and the image tag it was built from
(`python image <short sha>`, or `python image dev` for a local `make py-build`). It's
there so a participant can say which build they're on without digging through
`docker inspect`.

It's plain CSS -- `py-base/custom.css` -- loaded through JupyterLab's supported
`LabApp.custom_css` hook, switched on in `py-base/jupyter_server_config.py`. The tag is
appended to the stylesheet as a second `:root` block from the `OHW_IMAGE_TAG` build arg,
which CI fills in with the short sha.

The one fiddly part is *where* the file lives. JupyterLab serves it from
`ServerApp.static_custom_path`, which is only
`[~/.jupyter/custom, <jupyter_server package>/static/custom]` -- not the full Jupyter
config path, so `/etc/jupyter/custom` doesn't work, and the trait isn't configurable.
The hub mounts a volume over `/home/jovyan`, which hides anything baked into
`~/.jupyter`, so the Dockerfile installs it into the `jupyter_server` package instead
and asks the interpreter where that is rather than hardcoding a python version.

A side effect worth knowing: `~/.jupyter/custom` is searched first, so a participant who
writes their own `~/.jupyter/custom/custom.css` replaces the banner with it. That's a
reasonable escape hatch, not a bug.

`ci/smoke-test.sh` step 10 covers all of this -- that the route answers 200, that the
stylesheet carries the wordmark and the right tag, that `/lab` links it, and that the
`.jp-Launcher-cwd` class the banner hangs off still exists in the built lab assets.

## Testing user-generated environments

Our Python environment are now using [pixi](https://pixi.sh/latest/) to build and manage Conda environments, and [pixi-kernel](https://github.com/renan-r-santos/pixi-kernel) to allow for user installed environments.

The base (default) environment is built up of multiple features, each one corresponding to a specific tutorial. It's fine to overlap dependencies between tutorials, as that makes sure we don't remove them inadvertantly.

To add dependencies for a tutorial, `pixi add -f year-tutorial deps...`, for example: `pixi add -f 25-data-acccess numpy cartopy pandas gsw matplotlib seaborn cmocean cmcrameri tqdm seaborn argopy ipyleaflet searvey shapely cftime ioos_qc cf_xarray`.

Then for a new tutorial, the feature needs to be added to the `features` list for the environment in `pixi.toml`.

```toml
[environments]
default = {features = ["25-data-access"]}
```

Then run `pixi install` and pixi will figure out all the transitive dependencies for multiple deployment environments (Mac and Linux, Windows can be added easily) and try to lock the most common environment for all of them.

If packages are being added to an existing feature that is already part of the default feature, then `pixi install` should not need to be run as the lock file will be updated during `pixi add`.

### R environment

The R image images use [`nb_conda_kernels` ](https://github.com/Anaconda-Platform/nb_conda_kernels) which allows our users to create their own Conda environments.

This makes it so that we don't have to package everything into the images to start with.

To test that environments can be created, launch JupyterLab in one of the images.

- `conda create -n <env-name> <requirements>`, and make sure one of the requirements is a Jupyter kernel, like `ipykernel`.
- Try `conda activate <env-name>` and seeing if it's different than the base environment.
- The JupyerLab new notebook/console creation screen should now show options for `<env-name>`. This can sometimes take a few minutes before `nb_conda_kernels` sees it.
