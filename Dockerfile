FROM --platform=linux/amd64 ubuntu:22.04 AS build
LABEL author="devros42" \
      maintainer="devros42"

# Linux x64 CLI checksum from https://www.getmonero.org/downloads/hashes.txt
ENV MONERO_VERSION=0.18.5.3 MONERO_SHA256=3333d0e04c9cbe3023e7e2b6dd369c407f36bb8df5b05fb0a19d7685b3d56dfc

RUN apt-get update && apt-get install --no-install-recommends -y ca-certificates curl bzip2 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /root

RUN curl --fail --show-error --location --retry 3 \
    "https://downloads.getmonero.org/cli/monero-linux-x64-v${MONERO_VERSION}.tar.bz2" \
    --output monero.tar.bz2 && \
    echo "${MONERO_SHA256}  monero.tar.bz2" | sha256sum -c - && \
    tar -xjf monero.tar.bz2 --strip-components=1 \
        "monero-x86_64-linux-gnu-v${MONERO_VERSION}/monerod" && \
    rm monero.tar.bz2

FROM --platform=linux/amd64 ubuntu:22.04

RUN apt-get update && apt-get install --no-install-recommends -y wget && \
    rm -rf /var/lib/apt/lists/*
RUN useradd -ms /bin/bash monero && mkdir -p /home/monero/.bitmonero && chown -R monero:monero /home/monero/.bitmonero
USER monero
WORKDIR /home/monero

COPY --chown=monero:monero --from=build /root/monerod /home/monero/monerod

# blockchain location
VOLUME /home/monero/.bitmonero

EXPOSE 18080 18081 18089

HEALTHCHECK --interval=30s --timeout=5s CMD wget --no-verbose --tries=1 -O /dev/null http://127.0.0.1:18081/get_info || exit 1

ENTRYPOINT ["./monerod"]
CMD ["--config-file=/usr/local/monerod.conf", "--non-interactive"]

