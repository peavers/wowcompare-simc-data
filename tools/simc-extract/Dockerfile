ARG SIMC_SHA=1e6dffdae11b58a05a86bd562a7d262a9154e129

FROM debian:12-slim AS builder
ARG SIMC_SHA

RUN apt-get update && apt-get install -y --no-install-recommends \
        git ca-certificates cmake g++ make ninja-build \
        libcurl4-openssl-dev zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN git init simc \
    && cd simc \
    && git remote add origin https://github.com/simulationcraft/simc.git \
    && git fetch --depth=1 origin "${SIMC_SHA}" \
    && git checkout FETCH_HEAD

WORKDIR /src/simc/build
RUN cmake -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DSC_NO_NETWORKING=ON \
        -DBUILD_GUI=OFF \
        .. \
    && ninja simc

FROM debian:12-slim AS runtime
ARG SIMC_SHA
ENV SIMC_SHA=${SIMC_SHA}

RUN apt-get update && apt-get install -y --no-install-recommends \
        libstdc++6 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /src/simc/build/simc /usr/local/bin/simc
COPY extract.sh /usr/local/bin/extract.sh
RUN chmod +x /usr/local/bin/extract.sh

WORKDIR /out
ENTRYPOINT ["/usr/local/bin/extract.sh"]
