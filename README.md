# Custom MediaMTX Docker Image (GHCR)

This repository builds a custom Docker image based on the official [MediaMTX](https://hub.docker.com/r/bluenviron/mediamtx) image, adding AWS CLI capabilities, and pushes it to GitHub Container Registry (GHCR).

## How it works

- The Dockerfile uses the official MediaMTX image as a base and adds the AWS CLI package.
- A GitHub Actions workflow checks for new releases of the official MediaMTX image (on push to main, on a schedule, or manually).
- If a new version is found, it automatically builds and pushes both variants (standard and ffmpeg) to GHCR.

## Image Variants

For each MediaMTX release, two images are built:
- `ghcr.io/<owner>/mediamtx:<version>` - Standard variant
- `ghcr.io/<owner>/mediamtx:<version>-ffmpeg` - FFmpeg variant

## Workflow Triggers

The workflow runs on:
- Pushes to the `main` branch
- A daily schedule (6am UTC)
- Manual dispatch via the GitHub Actions UI

## How the Workflow Works

- **Fetch latest upstream tag:**
  - Uses a shell step with `curl` and `jq` to fetch the latest stable tag from Docker Hub for `bluenviron/mediamtx`.
- **Matrix build strategy:**
  - Builds both standard and `-ffmpeg` variants in parallel using a matrix strategy.
- **Compare with last built tag:**
  - If the tag is new, proceeds to build and push both variants.
- **Log in to GHCR:**
  - Uses `docker/login-action` to authenticate to GitHub Container Registry with the built-in `GITHUB_TOKEN`.
- **Build and push:**
  - Uses `docker/build-push-action` to build both image variants with the correct base tags and push to GHCR.
- **Update last built tag:**
  - Stores the last built tag in `.last_built_tag` and commits it to the repository.

## Usage

The built images include AWS CLI functionality on top of MediaMTX capabilities. Use them as you would the standard MediaMTX images:

```sh
docker run --rm -p 8554:8554 ghcr.io/<your-org-or-username>/mediamtx:<tag>
```

## Manual build

To build and run locally:
```sh
# Standard variant
docker build --build-arg VERSION_TAG=<tag> -t my-mediamtx:local .

# FFmpeg variant  
docker build --build-arg VERSION_TAG=<tag>-ffmpeg -t my-mediamtx:local-ffmpeg .

# Run
docker run --rm -p 8554:8554 my-mediamtx:local
```

## GitHub Actions

- The workflow is defined in `.github/workflows/rebuild-on-upstream.yml`.
- It uses:
  - A shell step to fetch the latest upstream tag with `curl` and `jq`.
  - Matrix strategy to build both standard and ffmpeg variants in parallel.
  - [docker/login-action](https://github.com/docker/login-action) for GHCR authentication.
  - [docker/build-push-action](https://github.com/docker/build-push-action) to build and push the images.
  - [stefanzweifel/git-auto-commit-action](https://github.com/stefanzweifel/git-auto-commit-action) to update the last built tag.

## Customization

- Edit the Dockerfile to add additional packages or configuration.
- The workflow automatically handles both MediaMTX variants (standard and ffmpeg).

## License

MIT
