FROM rust:latest as chef

RUN cargo install cargo-chef 
WORKDIR /app

FROM chef as planner

COPY . .
RUN cargo chef prepare  --recipe-path recipe.json

FROM chef as builder

COPY --from=planner /app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json
COPY . .
RUN cargo build --release --bin app

FROM debian:buster-slim as runtime

COPY --from=builder /app/target/release/app /usr/local/bin

ENTRYPOINT ["/usr/local/bin/app"]