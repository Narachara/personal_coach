# Phase 1: Prepare the build environment and cache dependencies
FROM rust:1 AS chef
RUN cargo install cargo-chef
WORKDIR /app

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

# Phase 2: Build the application with cached dependencies
FROM chef AS builder
COPY --from=planner /app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json
COPY . .

# Install the Dioxus CLI (dx)
RUN curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
RUN cargo binstall dioxus-cli --root /usr/local/cargo -y --force
ENV PATH="/usr/local/cargo/bin:$PATH"

# Create the final Web bundle (includes `server`)
RUN dx bundle --platform web

# Phase 3: Final runtime container
FROM chef AS runtime

# Set environment variables
ENV PORT=8080
ENV IP=0.0.0.0

# Copy server binary and static assets
COPY --from=builder /app/target/dx/myapp/release/web/ /usr/local/app

# Expose the web port
EXPOSE 8080

WORKDIR /usr/local/app
ENTRYPOINT [ "/usr/local/app/server" ]