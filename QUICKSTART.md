# Quick Start - Complete Setup in 10 Minutes

Follow these steps in order to get MSG Viewer running from your private GitHub Container Registry.

## Step 1: Import the Upstream Repository (2 minutes)

You need to create a private copy of the MSG Viewer source code. **Note: We use "Import" instead of "Fork" because GitHub doesn't allow forks to be more private than the upstream.**

**Option A - Web Browser (Easiest)**:
1. Visit: **https://github.com/new/import**
2. In "Your old repository's clone URL": `https://github.com/molotochok/msg-viewer.git`
3. Owner: Select `ngttech`
4. Repository name: `msg-viewer` (IMPORTANT: exactly this name)
5. Privacy: Select **Private**
6. Click **"Begin import"**
7. Wait 1-2 minutes for import to complete (you'll get an email)

**Option B - GitHub CLI** (if installed):
```bash
# Import creates a private copy (not a fork)
gh repo create ngttech/msg-viewer --private --clone=false
git clone --bare https://github.com/molotochok/msg-viewer.git
cd msg-viewer.git
git push --mirror https://github.com/ngttech/msg-viewer.git
cd ..
rm -rf msg-viewer.git
```

✅ **Verify**: Visit https://github.com/ngttech/msg-viewer and confirm it shows "(Private)" badge and has all the code

---

## Step 2: Create the Docker Repository (2 minutes)

Create a new repository to host the Docker configuration:

**Option A - Web Browser (Easiest)**:
1. Visit: https://github.com/new
2. Set owner to: `ngttech`
3. Repository name: `msg-viewer-docker`
4. Description: `Docker deployment configuration for MSG Viewer`
5. Select: **Private**
6. **DO NOT** check "Add a README" or any other initialization options
7. Click **Create repository**

**Option B - GitHub CLI** (if installed):
```bash
gh repo create ngttech/msg-viewer-docker --private --description "Docker deployment configuration for MSG Viewer"
```

✅ **Verify**: Visit https://github.com/ngttech/msg-viewer-docker and confirm it's empty and private

---

## Step 3: Push Docker Configuration to GitHub (1 minute)

Open PowerShell in the `msg-viewer-docker` directory and run:

```powershell
cd "c:\Users\MartinGonzalez\OneDrive - NGT TECHNOLOGY\Documents\CursorAI\MSG_VIEWER\msg-viewer-docker"

git init
git add .
git commit -m "Initial commit: Docker configuration for MSG Viewer"
git remote add origin https://github.com/ngttech/msg-viewer-docker.git
git branch -M main
git push -u origin main
```

You may be prompted to authenticate with GitHub.

✅ **Verify**: Refresh https://github.com/ngttech/msg-viewer-docker and you should see all files

---

## Step 4: Wait for Image Build (3-5 minutes)

The GitHub Actions workflow will automatically start building the Docker image:

1. Visit: https://github.com/ngttech/msg-viewer-docker/actions
2. You should see a workflow run called "Build and Publish to GHCR"
3. Click on it to watch the progress
4. Wait for it to show a green checkmark ✅

If the build **fails** with authentication errors accessing `ngttech/msg-viewer`:

1. Edit `.github/workflows/publish-ghcr.yml`
2. Change the `build-args` section to:
   ```yaml
   build-args: |
     SOURCE_REPO=https://x-access-token:${{ secrets.GITHUB_TOKEN }}@github.com/ngttech/msg-viewer.git
     SOURCE_REF=main
   ```
3. Commit and push this change

✅ **Verify**: Build completes successfully with green checkmark

---

## Step 5: Verify Package Was Published (1 minute)

1. Visit: https://github.com/orgs/ngttech/packages (or https://github.com/ngttech?tab=packages)
2. You should see a package named `msg-viewer`
3. Click on it
4. You should see tags like `latest` and `main-<sha>`

✅ **Verify**: Package `msg-viewer` is visible with `latest` tag

---

## Step 6: Deploy on Your Server (3 minutes)

On your target server (the one where you want to run MSG Viewer):

### 6.1 Create a GitHub Personal Access Token

1. Visit: https://github.com/settings/tokens
2. Click "Generate new token" → "Generate new token (classic)"
3. Give it a name: `msg-viewer-server`
4. Select scopes:
   - ✅ `read:packages`
   - ✅ `repo` (required for private repos)
5. Click "Generate token"
6. **COPY THE TOKEN** (you won't see it again!)

### 6.2 Authenticate Docker to GHCR

On your server, run:

```bash
echo YOUR_TOKEN_HERE | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin
```

Replace:
- `YOUR_TOKEN_HERE` with the token you just created
- `YOUR_GITHUB_USERNAME` with your GitHub username

✅ **Verify**: You should see "Login Succeeded"

### 6.3 Clone and Deploy

```bash
# Clone the docker repository
git clone https://github.com/ngttech/msg-viewer-docker.git
cd msg-viewer-docker

# Pull and start
docker-compose pull
docker-compose up -d

# Check status
docker ps | grep msg-viewer
```

✅ **Verify**: Container is running with status "Up" and "healthy"

### 6.4 Test the Application

1. Open browser to: `http://your-server-ip:8080`
2. You should see the MSG Viewer interface
3. Try uploading a .msg file to test

✅ **Verify**: Application loads and can parse .msg files

---

## Done! 🎉

Your MSG Viewer is now running from your private GitHub Container Registry.

## Common Issues

### Authentication error when pulling image
- **Problem**: `unauthorized: authentication required`
- **Solution**: Run the `docker login ghcr.io` command again with your PAT

### Build fails with "fatal: could not read Username"
- **Problem**: Workflow can't access private `ngttech/msg-viewer`
- **Solution**: Update the workflow's `build-args` as shown in Step 4

### Port 8080 already in use
- **Problem**: Another service is using port 8080
- **Solution**: Edit `docker-compose.yml` and change `"8080:80"` to `"8081:80"` (or any free port)

---

## Next Steps

- Read [README.md](README.md) for detailed deployment documentation
- Set up HTTPS with a reverse proxy (Nginx, Traefik, Caddy)
- Configure automated updates
- Set up monitoring

## Need Help?

- Check [SETUP.md](SETUP.md) for detailed explanations
- Review [README.md](README.md) for advanced configuration
- Check GitHub Actions logs for build issues
