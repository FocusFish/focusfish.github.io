# focusfish.github.io

Contains documentation for UVMS produced by [mkdocs material](https://squidfunk.github.io/mkdocs-material).

## Setup

See [getting started](https://squidfunk.github.io/mkdocs-material/getting-started/)
for setup steps. Either install mkdocs-material through pip or run it with Docker.

### Docker based

The image `squidfunk/mkdocs-material` comes with some packages pre-installed,
but lacks e.g. mike (versioning). The Dockerfile in this repo installs those
missing packages (see requirements.txt) and is available at [Docker
hub](https://hub.docker.com/r/uvms/mkdocs-material).

```
# Run the container, the default command is `mkdocs serve`
docker run --rm -it -p 8000:8000 -v ${PWD}:/docs docker.io/uvms/mkdocs-material:latest
```

After starting the container (`docker run ...`) the documentation is available
at `http://localhost:8000/`.

### Non-Docker based

It's recommended to use a virtual environment for non-Docker based setups. For
example, on Ubuntu:

1. python3 -m venv venv/
2. source venv/bin/activate
3. pip install -r requirements.txt

Don't forget to activate the virtual environment (`source venv/bin/activate`)
when opening a new shell/restarting/etc.

## Writing documentation

The documentation lives in the docs folder. When writing it's convenient to
have a live preview of it which can be achieved with:

```
mkdocs serve
```

### Templating

With the [macros](https://mkdocs-macros-plugin.readthedocs.io/en/latest/)
plugin the markdown files are run through a jinja2 templating engine. To
include a template variable:

1. add it under `extra` in `mkdocs.yml` and then reference it in the markdown
   file like `{{ my_variable }}`
1. if the variable needs to be updated automatically, update
   `.github/workflows/build-documentation.yml` step `Update versions` to
   include the new template variable

## Versioning

The documentation is versioned using [mike](https://github.com/jimporter/mike).
There's also some info on it on the
[mkdocs material](https://squidfunk.github.io/mkdocs-material/setup/setting-up-versioning/)
site.

There's an equivalent preview feature in mike with:

```
mike serve
```

Bear in mind that for writing new documentation the preview function of mkdocs
is better suited since it doesn't involve running `mike deploy ...` first.

## Publising

All publishing is done through the CI job
`.github/workflows/build-documentation.yml` (GitHub actions). On PR the
documentation is built with `mkdocs build` to verify that it can be built. Once
merged to main the job will build (`mike deploy ...`) and publish a new version
to [dev](https://focusfish.github.io/dev/).

To create a release, the job needs to be manually started
(`GitHub Actions tab->Build documentation->Run workflow`).
The version should be the latest released UVMS version (e.g. 4.3.4).

Upon completion the new version of the documentation will be available at:
[focusfish.github.io](https://focusfish.github.io/).

