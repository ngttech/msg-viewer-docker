# MSG Viewer - Docker Deployment

Docker deployment configuration for [MSG Viewer](https://github.com/molotochok/msg-viewer), a tool to read Outlook .msg files in your browser without sending data to external servers.

## Overview

This repository contains:
- `Dockerfile` - Multi-stage build that clones the source from `ngttech/msg-viewer` and builds a production-ready image
- `docker-compose.yml` - Compose configuration to pull and run the prebuilt image from GitHub Container Registry (GHCR)
- `nginx.conf` - Nginx configuration with security headers and caching
- GitHub Actions workflow to automatically build and publish images to GHCR

## Prerequisites

- Docker Desktop (Windows/Mac) or Docker Engine (Linux)
- GitHub Personal Access Token (PAT) for pulling private images

## Quick Start - Deploy from GHCR

### Step 1: Authenticate to GitHub Container Registry

Since this is a private image, you need to authenticate to GHCR:

1. **Create a Personal Access Token (PAT)**:
   - Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
   - Generate new token with these scopes:
     - `read:packages` (required to pull images)
     - `repo` (required for private repositories)
   - Save the token securely

2. **Login to GHCR**:
   ```bash
   echo YOUR_PAT_TOKEN | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin
   ```

   Replace `YOUR_PAT_TOKEN` with your actual token and `YOUR_GITHUB_USERNAME` with your GitHub username.

### Step 2: Deploy with Docker Compose

1. **Clone this repository**:
   ```bash
   git clone https://github.com/ngttech/msg-viewer-docker.git
   cd msg-viewer-docker
   ```

2. **Start the container**:
   ```bash
   docker-compose up -d
   ```

3. **Access the application**:
   Open your browser and navigate to: `http://localhost:8080`

4. **Stop the container**:
   ```bash
   docker-compose down
   ```

### Step 3: Update to Latest Version

To update to the latest version:

```bash
docker-compose pull
docker-compose up -d
```

## Alternative: Run with Docker CLI

```bash
# Pull the image
docker pull ghcr.io/ngttech/msg-viewer:latest

# Run the container
docker run -d \
  --name msg-viewer \
  -p 8080:80 \
  --restart unless-stopped \
  ghcr.io/ngttech/msg-viewer:latest

# Stop the container
docker stop msg-viewer
docker rm msg-viewer
```

## Configuration

### Change Port

Edit `docker-compose.yml` and modify the port mapping:

```yaml
ports:
  - "YOUR_PORT:80"  # Change YOUR_PORT to your preferred port
```

### Use Specific Version

Instead of `latest`, you can pin to a specific version:

```yaml
image: ghcr.io/ngttech/msg-viewer:v1.0.0  # or use SHA tag
```

## Building Locally (Optional)

If you want to build the image locally instead of pulling from GHCR:

```bash
docker build -t msg-viewer:local .
```

Then update `docker-compose.yml` to use `image: msg-viewer:local`.

### Build Arguments

The Dockerfile supports customization via build arguments:

```bash
docker build \
  --build-arg SOURCE_REPO=https://github.com/ngttech/msg-viewer.git \
  --build-arg SOURCE_REF=main \
  -t msg-viewer:custom .
```

- `SOURCE_REPO`: Git repository URL (default: `https://github.com/ngttech/msg-viewer.git`)
- `SOURCE_REF`: Git branch, tag, or commit (default: `main`)

## Troubleshooting

### Authentication Errors

**Error**: `unauthorized: authentication required`

**Solution**: Make sure you've logged in to GHCR with a valid PAT that has `read:packages` and `repo` scopes.

### Port Already in Use

**Error**: `Bind for 0.0.0.0:8080 failed: port is already allocated`

**Solution**: Change the port in `docker-compose.yml` or stop the service using port 8080.

### Container Health Check Failing

Check container logs:
```bash
docker logs msg-viewer
```

Inspect health status:
```bash
docker inspect msg-viewer | grep -A 10 Health
```

## Production Deployment

For production environments:

1. **Use HTTPS**: Deploy behind a reverse proxy (Nginx Proxy Manager, Traefik, Caddy)
2. **Pin versions**: Use specific version tags instead of `latest`
3. **Set resource limits**:
   ```yaml
   deploy:
     resources:
       limits:
         cpus: '0.5'
         memory: 512M
   ```
4. **Monitor health**: Set up monitoring for the health check endpoint
5. **Regular updates**: Periodically pull and deploy new versions

## Image Tags

Images are automatically built and tagged by GitHub Actions:

- `latest` - Latest commit on main branch
- `main-<sha>` - Specific commit from main branch
- `v*.*.*` - Semantic version tags (e.g., `v1.0.0`, `v1.0`, `v1`)

## Architecture

The Docker image uses a multi-stage build:

1. **Builder Stage** (Bun):
   - Clones source from `ngttech/msg-viewer`
   - Installs dependencies
   - Builds static site with `bun ./build.ts`

2. **Runtime Stage** (Nginx Alpine):
   - Copies built assets from builder
   - Serves files via Nginx
   - Final image size: ~20-30 MB

## Privacy & Security

- All .msg file parsing happens **client-side** in the browser
- No data is sent to external servers
- The container only serves static files
- Same privacy model as the upstream project

## License

This Docker configuration is provided as-is. The MSG Viewer application itself is licensed under the MIT License by Markiian Karpa. See the upstream repository for details: https://github.com/molotochok/msg-viewer

## Related Repositories

- **Source Code**: [ngttech/msg-viewer](https://github.com/ngttech/msg-viewer) (private fork)
- **Upstream**: [molotochok/msg-viewer](https://github.com/molotochok/msg-viewer) (original project)
- **Docker Config**: [ngttech/msg-viewer-docker](https://github.com/ngttech/msg-viewer-docker) (this repository)

## Support

For issues with:
- **Docker deployment**: Open an issue in this repository
- **Application functionality**: Check the upstream repository
- **Authentication**: Verify your GitHub PAT has correct scopes
