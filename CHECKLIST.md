# Setup Checklist

Use this checklist to track your progress setting up MSG Viewer Docker deployment.

## Prerequisites
- [ ] Docker Desktop installed and running
- [ ] Git installed
- [ ] GitHub account with access to `ngttech` organization

---

## Part 1: Create GitHub Repositories

### Task 1: Import the Source Code Repository (Not Fork)
Note: Use Import instead of Fork because forks cannot be made private.
- [ ] Visit https://github.com/new/import
- [ ] Enter clone URL: `https://github.com/molotochok/msg-viewer.git`
- [ ] Set owner: `ngttech`
- [ ] Set name: `msg-viewer` (exactly)
- [ ] Set privacy: **Private**
- [ ] Click "Begin import"
- [ ] Wait for import to complete (1-2 minutes, check email)
- [ ] Verify: https://github.com/ngttech/msg-viewer shows "(Private)" and has code

### Task 2: Create the Docker Repository
- [ ] Visit https://github.com/new
- [ ] Set owner: `ngttech`
- [ ] Set name: `msg-viewer-docker`
- [ ] Description: "Docker deployment configuration for MSG Viewer"
- [ ] Select: Private
- [ ] **Do NOT** initialize with README
- [ ] Click "Create repository"
- [ ] Verify: https://github.com/ngttech/msg-viewer-docker exists and is private

---

## Part 2: Push Code to GitHub

### Task 3: Push Docker Configuration
- [ ] Open PowerShell
- [ ] Navigate to: `msg-viewer-docker` directory
- [ ] Run: `.\push-to-github.ps1`
  
  OR manually run:
  ```powershell
  git init
  git add .
  git commit -m "Initial commit: Docker configuration for MSG Viewer"
  git remote add origin https://github.com/ngttech/msg-viewer-docker.git
  git branch -M main
  git push -u origin main
  ```
- [ ] Verify: Files visible at https://github.com/ngttech/msg-viewer-docker

---

## Part 3: Build and Publish

### Task 4: Monitor First Build
- [ ] Visit: https://github.com/ngttech/msg-viewer-docker/actions
- [ ] See workflow: "Build and Publish to GHCR"
- [ ] Click on the workflow run
- [ ] Wait for completion (3-5 minutes)

**If build fails with authentication error:**
- [ ] The workflow can't access private `ngttech/msg-viewer`
- [ ] Edit `.github/workflows/publish-ghcr.yml`
- [ ] Change `build-args` to include token:
  ```yaml
  build-args: |
    SOURCE_REPO=https://x-access-token:${{ secrets.GITHUB_TOKEN }}@github.com/ngttech/msg-viewer.git
    SOURCE_REF=main
  ```
- [ ] Commit and push the change
- [ ] Wait for new workflow run to complete

### Task 5: Verify Package
- [ ] Visit: https://github.com/orgs/ngttech/packages
- [ ] See package: `msg-viewer`
- [ ] Click on package
- [ ] See tags: `latest`, `main-<sha>`
- [ ] Verify package is private

---

## Part 4: Deploy to Server

### Task 6: Create GitHub Personal Access Token
- [ ] Visit: https://github.com/settings/tokens
- [ ] Click: "Generate new token (classic)"
- [ ] Name: `msg-viewer-server`
- [ ] Scopes: `read:packages` ✅ and `repo` ✅
- [ ] Click: "Generate token"
- [ ] Copy token (save it securely!)

### Task 7: Authenticate Docker to GHCR (on server)
On your target server, run:
```bash
echo YOUR_TOKEN | docker login ghcr.io -u YOUR_USERNAME --password-stdin
```
- [ ] Command returns: "Login Succeeded"

### Task 8: Clone and Deploy (on server)
```bash
git clone https://github.com/ngttech/msg-viewer-docker.git
cd msg-viewer-docker
docker-compose pull
docker-compose up -d
```
- [ ] Container starts successfully
- [ ] Run: `docker ps | grep msg-viewer`
- [ ] Container status shows: "Up" and "(healthy)"

### Task 9: Test Application
- [ ] Open browser: `http://server-ip:8080`
- [ ] See MSG Viewer interface
- [ ] Upload a test .msg file
- [ ] File parses and displays correctly

---

## ✅ Setup Complete!

Your MSG Viewer is now:
- ✅ Forked to your private repository
- ✅ Containerized with Docker
- ✅ Published to GitHub Container Registry
- ✅ Deployed and running on your server

---

## Optional: Next Steps

- [ ] Set up HTTPS with reverse proxy (Nginx, Traefik, Caddy)
- [ ] Configure automated image updates (cron in workflow)
- [ ] Set up monitoring/alerting
- [ ] Document deployment procedures for your team
- [ ] Configure backup/disaster recovery
- [ ] Test failover scenarios
- [ ] Create deployment runbook

---

## Troubleshooting

If you encounter issues, check:
- [ ] [QUICKSTART.md](QUICKSTART.md) - Step-by-step guide
- [ ] [README.md](README.md) - Detailed documentation
- [ ] [SETUP.md](SETUP.md) - In-depth setup instructions
- [ ] GitHub Actions logs for build errors
- [ ] Container logs: `docker logs msg-viewer`

---

## Support

For help with:
- **Docker/deployment**: Create issue in `ngttech/msg-viewer-docker`
- **Application bugs**: Check upstream `molotochok/msg-viewer`
- **GitHub/GHCR**: Review GitHub documentation or contact support
