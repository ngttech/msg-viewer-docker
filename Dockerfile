# Stage 1: Build the static site using Bun
FROM oven/bun:1 AS builder

# Install git for cloning the source repository
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Build arguments for source repository (can be overridden at build time)
ARG SOURCE_REPO=https://github.com/ngttech/msg-viewer.git
ARG SOURCE_REF=main

# Clone the source repository
RUN git clone --depth 1 --branch ${SOURCE_REF} ${SOURCE_REPO} src

WORKDIR /app/src

# Install dependencies
RUN bun install --frozen-lockfile

# Build the static site
RUN bun ./build.ts

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built static files from builder stage
COPY --from=builder /app/src/build /usr/share/nginx/html

# Copy LICENSE to comply with MIT license requirements
COPY --from=builder /app/src/LICENSE /usr/share/nginx/html/LICENSE

# Add metadata labels
LABEL org.opencontainers.image.source="https://github.com/ngttech/msg-viewer-docker"
LABEL org.opencontainers.image.description="MSG Viewer - Read Outlook .msg files in your browser"
LABEL org.opencontainers.image.licenses="MIT"

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
