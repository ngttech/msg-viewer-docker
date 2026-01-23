# Setup Instructions

This document provides step-by-step instructions to set up the MSG Viewer Docker deployment on GitHub.

## Prerequisites

- GitHub account
- Git installed locally
- Docker Desktop installed and running

## Step 1: Import the Source Repository (Not Fork)

**Important**: GitHub does not allow forks to be more private than their upstream repository. Since the upstream is public, we must use **"Import repository"** instead of "Fork" to create a private copy.

1. **Via GitHub Web UI (Recommended)**:
   - Go to https://github.com/new/import
   - In "Your old repository's clone URL", enter: `https://github.com/molotochok/msg-viewer.git`
   - Owner: Select `ngttech`
   - Repository name: `msg-viewer` (exactly this name)
   - Privacy: **Private**
   - Click "Begin import"
   - Wait 1-2 minutes (GitHub will email you when complete)

   OR

2. **Via Git CLI (Manual mirror)**:
   ```bash
   # First create an empty private repo
   gh repo create ngttech/msg-viewer --private --clone=false
   
   # Clone the upstream as a bare repo
   git clone --bare https://github.com/molotochok/msg-viewer.git
   cd msg-viewer.git
   
   # Push to your new private repo
   git push --mirror https://github.com/ngttech/msg-viewer.git
   
   # Cleanup
   cd ..
   rm -rf msg-viewer.git
   ```

3. **Verify the import**:
   - Go to https://github.com/ngttech/msg-viewer
   - Confirm it shows "(Private)" badge
   - Confirm all files and history are present

## Step 2: Create the Docker Repository

Create a new private repository for the Docker configuration:

1. **Via GitHub Web UI**:
   - Go to https://github.com/new
   - Owner: Select "ngttech"
   - Repository name: `msg-viewer-docker`
   - Description: "Docker deployment configuration for MSG Viewer"
   - Visibility: **Private**
   - **Do NOT** initialize with README (we already have files)
   - Click "Create repository"

   OR

2. **Via GitHub CLI** (if you install it):
   ```bash
   gh repo create ngttech/msg-viewer-docker --private --description "Docker deployment configuration for MSG Viewer"
   ```

## Step 3: Push Local Files to GitHub

1. **Initialize git in the msg-viewer-docker folder**:
   ```bash
   cd msg-viewer-docker
   git init
   git add .
   git commit -m "Initial commit: Docker configuration for MSG Viewer"
   ```

2. **Add remote and push**:
   ```bash
   git remote add origin https://github.com/ngttech/msg-viewer-docker.git
   git branch -M main
   git push -u origin main
   ```

## Step 4: Configure GitHub Container Registry

The GitHub Actions workflow will automatically publish to GHCR when you push to the main branch. However, you need to ensure the package visibility is set correctly:

1. After the first workflow run (which will be triggered by the push above), go to:
   https://github.com/orgs/ngttech/packages

2. Find the `msg-viewer` package

3. Click "Package settings"

4. Under "Danger Zone", ensure visibility matches your preference (Private recommended)

5. Under "Manage Actions access", ensure the repository `ngttech/msg-viewer-docker` has "Write" access

## Step 5: Verify the Build

1. Go to your repository on GitHub: https://github.com/ngttech/msg-viewer-docker

2. Click on the "Actions" tab

3. You should see a workflow run for "Build and Publish to GHCR"

4. Wait for it to complete (usually 2-5 minutes)

5. Once complete, verify the image exists:
   - Go to https://github.com/orgs/ngttech/packages
   - You should see a package named `msg-viewer`
   - Click on it to see the available tags (latest, SHA, etc.)

## Step 6: Test Deployment on Another Server

On your target server:

1. **Authenticate to GHCR**:
   ```bash
   echo YOUR_PAT_TOKEN | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin
   ```

   To create a PAT:
   - Go to https://github.com/settings/tokens
   - Generate new token (classic)
   - Select scopes: `read:packages` and `repo`
   - Copy the token

2. **Clone the docker repository**:
   ```bash
   git clone https://github.com/ngttech/msg-viewer-docker.git
   cd msg-viewer-docker
   ```

3. **Pull and run**:
   ```bash
   docker-compose pull
   docker-compose up -d
   ```

4. **Verify**:
   - Open browser to `http://server-ip:8080`
   - Test uploading a .msg file

## Updating the Application

To update the MSG Viewer application in the future:

### Option A: Update via Fork Sync (Recommended)

1. Go to your fork: https://github.com/ngttech/msg-viewer
2. Click "Sync fork" button (if available)
3. Go to msg-viewer-docker Actions: https://github.com/ngttech/msg-viewer-docker/actions
4. Click "Build and Publish to GHCR" workflow
5. Click "Run workflow" → "Run workflow"
6. Wait for build to complete
7. On servers, run: `docker-compose pull && docker-compose up -d`

### Option B: Manual Update

If you made custom changes to your fork:

1. Update your `ngttech/msg-viewer` fork with desired changes
2. Trigger a rebuild:
   - Push a commit to `ngttech/msg-viewer-docker` main branch, OR
   - Manually trigger the workflow via GitHub Actions UI
3. On servers, run: `docker-compose pull && docker-compose up -d`

## Troubleshooting

### Cannot access ngttech/msg-viewer during build

**Error**: `fatal: could not read Username for 'https://github.com'`

**Solution**: The repository needs to be public OR you need to configure the workflow with credentials. For private repos, update the Dockerfile to use a token:

Add to the workflow file (`.github/workflows/publish-ghcr.yml`):

```yaml
build-args: |
  SOURCE_REPO=https://x-access-token:${{ secrets.GITHUB_TOKEN }}@github.com/ngttech/msg-viewer.git
  SOURCE_REF=main
```

This uses the workflow's GITHUB_TOKEN which has read access to repositories in the same organization.

### Workflow fails with 403 Forbidden

**Solution**: Ensure the workflow has correct permissions. In `.github/workflows/publish-ghcr.yml`, verify:

```yaml
permissions:
  contents: read
  packages: write
```

## Next Steps

- Set up automated updates on a schedule (add a cron trigger to the workflow)
- Configure monitoring/alerting for the deployed container
- Set up a reverse proxy with HTTPS
- Document your specific deployment procedures

## Questions?

Contact your system administrator or refer to:
- [README.md](README.md) - User documentation
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Container Registry Documentation](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
