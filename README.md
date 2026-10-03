# ddclient

Containerized [ddclient](https://ddclient.net) for running as a one-shot
job (e.g. a Kubernetes CronJob).

Multi-stage build on Alpine Linux:

1. Build stage compiles `ddclient` from a pinned commit on the upstream
   `main` branch (see the `DDCLIENT_COMMIT` build arg in the `Dockerfile`).
   This is currently needed because the distro package (and the latest
   tagged release, v4.0.0) doesn't yet include the Hetzner apex-domain fix
   (ddclient/ddclient#899). Bump `DDCLIENT_COMMIT` to a tagged release once
   one ships with that fix.
2. Runtime stage only installs the Perl runtime dependencies and copies the
   compiled `ddclient` binary over, running as an unprivileged `ddclient`
   user.

The container expects its configuration to be mounted at
`/ddclient/config/ddclient.conf`.

Image is published to `ghcr.io/lentzi90/ddclient` via the `build` GitHub
Actions workflow, triggered on pushes to `master` and on `v*` tags.

## Usage

```sh
docker run --rm -v /path/to/ddclient.conf:/ddclient/config/ddclient.conf:ro ghcr.io/lentzi90/ddclient
```

See https://github.com/lentzi90/personal-cloud/tree/main/ddclient for an
example of how this image is deployed to Kubernetes.
