FROM ubuntu:20.04
LABEL maintainer="ghtsto"

ARG DEBIAN_FRONTEND="noninteractive"
ARG APT_MIRROR="archive.ubuntu.com"
ARG PLATFORM_ARCH="amd64"

ARG CHIA_VERSION="1.3.3"

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2
ENV S6_KEEP_ENV=1
ENV S6_SERVICES_GRACETIME=8000

ENV LANG=C.UTF-8
ENV PS1="\u@\h:\w\\$ "

RUN \
  echo "*** installing packages ***" && \
    sed -i "s/archive.ubuntu.com/\"$APT_MIRROR\"/g" /etc/apt/sources.list && \
    apt update && \
    apt install -y \
      ca-certificates \
      tzdata \
      curl \
      git \
      bc \
      python3.8-venv \
      python3-distutils \ 
      python-is-python3 && \
    update-ca-certificates && \
    apt install -y openssl && \
  echo "*** install s6 overlay ***" && \
    # revert whenever this image gets updated to use s6 v3
    # S6_OVERLAY_VERSION=$(curl -sX GET "https://api.github.com/repos/just-containers/s6-overlay/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]') && \
    S6_OVERLAY_VERSION=v2.2.0.3 && \
    curl -J -L -o /tmp/s6-overlay-amd64.tar.gz https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz && \
    tar xzf /tmp/s6-overlay-amd64.tar.gz -C / --exclude='./bin' && \
    tar xzf /tmp/s6-overlay-amd64.tar.gz -C /usr ./bin && \
  echo "*** clone chia repo ***" && \
    git clone --depth 1 --branch ${CHIA_VERSION} https://github.com/Chia-Network/chia-blockchain.git /chia && \
  echo "*** setup chia ***" && \
    cd /chia && \
    git submodule update --init mozilla-ca && \
    python -m venv venv && \
    ln -s venv/bin/activate . && \
    . ./activate && \
    pip install --upgrade pip && \
    pip install wheel && \
    pip install --extra-index-url https://pypi.chia.net/simple/ miniupnpc==2.1 && \
    pip install -e . --extra-index-url https://pypi.chia.net/simple/ && \
  echo "*** cleanup build ***" && \
    apt-get purge -y \
      git \
      curl && \
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /tmp/* /var/lib/{apt,dpkg,cache,log}/

VOLUME /config /blockchain /keyring /wallet

COPY root/ /

ENTRYPOINT ["/init"]
