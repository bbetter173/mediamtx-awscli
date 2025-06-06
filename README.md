# Custom MediaMTX Docker Image (GHCR)

This repository builds a custom Docker image based on the official [MediaMTX](https://hub.docker.com/r/bluenviron/mediamtx) image, adding AWS CLI capabilities, and pushes it to GitHub Container Registry (GHCR).

## How it works

- The Dockerfile uses the official MediaMTX FFmpeg image as a base and adds the AWS CLI package.
- A GitHub Actions workflow checks for new releases of the official MediaMTX image (on push to main, on a schedule, or manually).
- If a new version is found, it automatically builds and pushes the FFmpeg variant to GHCR.

## Why FFmpeg variant only?

We only build the FFmpeg variant because the standard MediaMTX image is built from scratch and contains no shell or package manager, making it impossible to add additional packages like AWS CLI. The FFmpeg variant is based on Alpine Linux and includes the necessary tools for customization.

## Image

For each MediaMTX release, one image is built:
- `ghcr.io/<owner>/mediamtx:<version>-ffmpeg` - FFmpeg variant with AWS CLI

## Workflow Triggers

The workflow runs on:
- Pushes to the `main` branch
- A daily schedule (6am UTC)
- Manual dispatch via the GitHub Actions UI

## How the Workflow Works

- **Fetch latest upstream tag:**
  - Uses a shell step with `curl` and `jq` to fetch the latest stable tag from Docker Hub for `bluenviron/mediamtx`.
- **Compare with last built tag:**
  - If the tag is new, proceeds to build and push the FFmpeg variant.
- **Log in to GHCR:**
  - Uses `docker/login-action` to authenticate to GitHub Container Registry with the built-in `GITHUB_TOKEN`.
- **Build and push:**
  - Uses `docker/build-push-action` to build the FFmpeg image variant with AWS CLI and push to GHCR.
- **Update last built tag:**
  - Stores the last built tag in `.last_built_tag` and commits it to the repository.

## Usage

The built images include AWS CLI functionality on top of MediaMTX capabilities. Use them as you would the standard MediaMTX images:

```sh
docker run --rm -p 8554:8554 ghcr.io/<your-org-or-username>/mediamtx:<tag>-ffmpeg
```

## Manual build

To build and run locally:
```sh
# Build FFmpeg variant with AWS CLI
docker build --build-arg VERSION_TAG=<tag>-ffmpeg -t my-mediamtx:local .

# Run
docker run --rm -p 8554:8554 my-mediamtx:local
```

## GitHub Actions

- The workflow is defined in `.github/workflows/rebuild-on-upstream.yml`.
- It uses:
  - A shell step to fetch the latest upstream tag with `curl` and `jq`.
  - [docker/login-action](https://github.com/docker/login-action) for GHCR authentication.
  - [docker/build-push-action](https://github.com/docker/build-push-action) to build and push the FFmpeg variant image.
  - [stefanzweifel/git-auto-commit-action](https://github.com/stefanzweifel/git-auto-commit-action) to update the last built tag.

## Customization

- Edit the Dockerfile to add additional packages or configuration.
- The workflow automatically builds the FFmpeg variant when new MediaMTX releases are detected.
