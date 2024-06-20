FROM debian:bookworm-slim AS rauc-bundler

# Environment
ENV DEBIAN_FRONTEND noninteractive

ENV RAUC_BUILD_DEPENDENCIES git \
    automake \
    build-essential \
    libtool \
    libjson-glib-dev \
    libdbus-1-dev \
    libcurl3-dev \
    libssl-dev \
    ca-certificates

# Add build and runtime dependencies
RUN apt update && apt upgrade -y

RUN apt install --no-install-recommends -y $RAUC_BUILD_DEPENDENCIES
RUN apt install --no-install-recommends -y squashfs-tools libjson-glib-1.0-0

ENV RAUC_VERSION v1.10.1

# Build and install RAUC
RUN git clone https://github.com/rauc/rauc.git /rauc && \
    cd /rauc && \
    git checkout "$RAUC_VERSION" && \
    ./autogen.sh && \
    ./configure --enable-json --prefix=/usr && \
    make install && \
    cd / && \
    rm -rf /rauc 

# Remove build dependencies
RUN apt remove -y $RAUC_BUILD_DEPENDENCIES && \
    apt autoremove -y --purge && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

RUN rauc --version

ENTRYPOINT ["rauc"]
