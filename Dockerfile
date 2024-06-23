FROM debian:bookworm-slim AS rauc-bundler

# Environment
ENV DEBIAN_FRONTEND noninteractive

ENV RAUC_BUILD_DEPENDENCIES git \
    automake \
    build-essential \
    meson \
    libtool \
    libglib2.0-dev \
    libssl-dev \
    ca-certificates

# Add build and runtime dependencies
RUN apt update && apt upgrade -y

RUN apt install --no-install-recommends -y $RAUC_BUILD_DEPENDENCIES
RUN apt install --no-install-recommends -y squashfs-tools libglib2.0-0 libssl3

ARG RAUC_VERSION=v1.11.3
ENV RAUC_VERSION=${RAUC_VERSION}

# Build and install RAUC using meson xor automake
RUN git clone https://github.com/rauc/rauc.git /rauc && \
    cd /rauc && \
    git checkout "$RAUC_VERSION"

RUN test ! -e /rauc/meson.build && exit 0; \
    cd /rauc && \
    meson setup build -Dnetwork=false -Dservice=false -Dstreaming=false -Djson=disabled && \
    meson compile -C build && \
    meson install -C build

RUN test -e /rauc/meson.build && exit 0; \
    cd /rauc && \
    ./autogen.sh && \
    ./configure --disable-network --disable-service --disable-streaming --disable-json && \
    make install

RUN rm -rf /rauc

# Remove build dependencies
RUN apt remove -y $RAUC_BUILD_DEPENDENCIES && \
    apt autoremove -y --purge && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p "/bundle/keys" "/bundle/input" "/bundle/output"

VOLUME [ "/bundle/keys", "/bundle/input", "/bundle/output" ]
WORKDIR "/bundle"
ENTRYPOINT ["rauc"]
