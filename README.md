# monero-full-node

Docker image for a Monero full node, maintained in this fork of
[kannix/monero-full-node](https://github.com/kannix/monero-full-node).
It packages the official Linux x64 CLI daemon **0.18.5.1** on Ubuntu 22.04.
Only `linux/amd64` is supported; ARM hosts need amd64 emulation.

## Build and check locally

```sh
docker build --platform linux/amd64 -t devros42/monero-full-node:local .
docker run --rm --network none devros42/monero-full-node:local --version
```

The version check exits without starting a node or syncing the blockchain.
The Dockerfile verifies the archive SHA256 before extracting only `monerod`.
When updating, use the **CLI** version and Linux x64 checksum from the
[official downloads](https://www.getmonero.org/downloads/) and
[signed checksum list](https://www.getmonero.org/downloads/hashes.txt).
Follow the [official verification guide](https://www.getmonero.org/resources/user-guides/verification-allos-advanced.html)
to authenticate that list. GUI releases can have a different version.

## Configuration and usage

The default command requires `/usr/local/monerod.conf`. Mount your reviewed
configuration there; the image does not embed the repository's configuration.
For example, from this checkout, when you intend to start a node:

```sh
docker run -d --restart=always --name=monerod \
  -v xmrchain:/home/monero/.bitmonero \
  --mount type=bind,src="$(pwd)/monerod.conf",dst=/usr/local/monerod.conf,readonly \
  -p 18080:18080 -p 18089:18089 \
  devros42/monero-full-node:local
```

This starts a node and downloads blockchain data. Keep your existing data volume
and reviewed configuration when replacing a container. Existing installations
that mount a configuration directory at `/usr/local` remain compatible.

The included configuration binds P2P on port 18080 and restricted RPC on 18089.
Unrestricted RPC on 18081 is bound to loopback inside the container and is used
by the health check; publishing that port does not make it reachable externally.
The health check tests HTTP responsiveness, not blockchain sync completion.
The daemon runs as the `monero` user, and its data directory is
`/home/monero/.bitmonero`. Existing bind-mounted data must be writable by that
user. Older images from before October 2018 ran as root, so their volume
ownership may need an explicit migration before upgrading.

## Workflows and image updates

Both GitHub Actions workflows are **manual only**:

- **Build Docker image** builds and performs a network-disabled version check
  without publishing. It uses the GitHub Actions BuildKit cache.
- **Build and Publish Docker Image** publishes
  `devros42/monero-full-node:latest` to Docker Hub using the existing
  `DOCKER_USERNAME` and `DOCKER_PASSWORD` secrets.

A source update does not update the published image until the publishing
workflow is explicitly run. Review and test an image before replacing a running
container; retain its data volume and configuration. Each workflow has a
15-minute job timeout to bound individual runs.

# Donations

I am supporting this image in my spare time and would be very happy about some donations to keep this going. You can support me by sending some XMR to: `47VCQgBjmLd1oMGKGcbVbzM1ND1qUWzs7Nonxip9cuNraJwVxDWQb1nU5tPfgYx4xLftnPiR1zPcgZBi4Mmoj3at39C7qp9`
