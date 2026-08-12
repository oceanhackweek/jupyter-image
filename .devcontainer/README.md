# Codespaces devcontainer

This devcontainer is for updating and trying the `py-base` pixi environment, not for
building the production Docker image (use `make py-build` / `docker compose` for that,
which also work here since Docker-in-Docker is enabled).

## Usage

- `cd py-base`
- `pixi add -f <feature-name> <packages...>` to add dependencies to a tutorial feature.
- `pixi install` to refresh the lockfile after editing `pixi.toml` by hand.
- `pixi run lab` to launch JupyterLab on port 8080 (forwarded automatically) and try the environment.
- `make py-build` (from the repo root) to build and smoke-test the real Docker image.
