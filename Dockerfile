FROM --platform=$BUILDPLATFORM cts/rust-aarch64-linux-gnu:1.88 AS appbuild
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "Host platform: $BUILDPLATFORM, image platform: $TARGETPLATFORM"
VOLUME ["/usr/app"]
WORKDIR /usr/app

# make dependency cache
COPY ./.cargo ./.cargo
COPY Cargo_stage1.toml ./
RUN mkdir src && echo "fn main() {}" > src/main.rs
ENV CC="aarch64-linux-gnu-gcc"
RUN cargo build --release --target aarch64-unknown-linux-gnu || true

# build actual sources
COPY Cargo.toml ./
COPY ./src ./src
ENV CC="aarch64-linux-gnu-gcc"
RUN cargo build --release --target aarch64-unknown-linux-gnu

# extract binary
FROM debian:trixie-slim
COPY --from=appbuild /usr/app/target/aarch64-unknown-linux-gnu/release/docker-stat-exporter /usr/local/sbin/docker-stat-exporter
ENTRYPOINT ["/usr/local/sbin/docker-stat-exporter"]
