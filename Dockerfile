# Usage: docker run --restart=always -v /var/data/blockchain-xmr:/home/monero/.bitmonero -p 18080:18080 -p 18081:18081 -p 18089:18089 --name=monero-full-node -v /mnt/cache/appdata/monero-node:/usr/local -td devros42/monero-full-node

FROM --platform=linux/amd64 ubuntu:latest AS build
LABEL author="devros42" \
      maintainer="devros42"
      

#ENV MONERO_VERSION=0.18.2.2 MONERO_SHA256=186800de18f67cca8475ce392168aabeb5709a8f8058b0f7919d7c693786d56b 
ENV MONERO_VERSION=0.18.3.3 MONERO_SHA256=47c7e6b4b88a57205800a2538065a7874174cd087eedc2526bee1ebcce0cc5e3

RUN apt-get update && apt-get install -y curl bzip2

WORKDIR /root

RUN curl https://dlsrc.getmonero.org/cli/monero-linux-x64-v$MONERO_VERSION.tar.bz2 -O &&\
  echo "$MONERO_SHA256  monero-linux-x64-v$MONERO_VERSION.tar.bz2" | sha256sum -c - &&\
  tar -xvf monero-linux-x64-v$MONERO_VERSION.tar.bz2 &&\
  rm monero-linux-x64-v$MONERO_VERSION.tar.bz2 &&\
  cp ./monero-x86_64-linux-gnu-v$MONERO_VERSION/monerod . &&\
  rm -r monero-*

FROM --platform=linux/amd64 ubuntu:latest

RUN apt-get update && apt-get install --no-install-recommends -y wget
RUN useradd -ms /bin/bash monero && mkdir -p /home/monero/.bitmonero && chown -R monero:monero /home/monero/.bitmonero
USER monero
WORKDIR /home/monero

COPY --chown=monero:monero --from=build /root/monerod /home/monero/monerod

# blockchain location
VOLUME /home/monero/.bitmonero

EXPOSE 18080 18081 18089

HEALTHCHECK --interval=30s --timeout=5s CMD wget --no-verbose --tries=1 --spider http://localhost:18081/get_info || exit 



ENTRYPOINT ["./monerod"]
CMD ["--config-file=/usr/local/monerod.conf", "--non-interactive"]

