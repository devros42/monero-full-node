# Usage: docker run --restart=always -v /var/data/blockchain-xmr:/home/monero/.bitmonero -p 18080:18080 -p 18081:18081 -p 18089:18089 --name=monero-full-node -v /mnt/cache/appdata/monero-node:/usr/local -td devros42/monero-full-node
FROM ubuntu:18.04 AS build

ENV MONERO_VERSION=0.18.1.0 MONERO_SHA256=9318e522a5cf95bc856772f15d7507fdef2c028e01f70d020078ad5e208f1304


RUN apt-get update && apt-get install -y curl bzip2

WORKDIR /root

RUN curl https://dlsrc.getmonero.org/cli/monero-linux-x64-v$MONERO_VERSION.tar.bz2 -O &&\
  echo "$MONERO_SHA256  monero-linux-x64-v$MONERO_VERSION.tar.bz2" | sha256sum -c - &&\
  tar -xvf monero-linux-x64-v$MONERO_VERSION.tar.bz2 &&\
  rm monero-linux-x64-v$MONERO_VERSION.tar.bz2 &&\
  cp ./monero-x86_64-linux-gnu-v$MONERO_VERSION/monerod . &&\
  rm -r monero-*

FROM ubuntu:18.04

RUN useradd -ms /bin/bash monero && mkdir -p /home/monero/.bitmonero && chown -R monero:monero /home/monero/.bitmonero
USER monero
WORKDIR /home/monero

COPY --chown=monero:monero --from=build /root/monerod /home/monero/monerod

# blockchain location
VOLUME /home/monero/.bitmonero

EXPOSE 18080 18081 18089


ENTRYPOINT ["./monerod"]
CMD ["--config-file=/usr/local/monerod.conf", "--non-interactive"]


