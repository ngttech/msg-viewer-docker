# PowerShell script to initialize git and push to GitHub
# Run this AFTER you've created the ngttech/msg-viewer-docker repository on GitHub

Write-Host "MSG Viewer Docker - Push to GitHub Script" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check if git is initialized
if (Test-Path ".git") {
    Write-Host "Git repository already initialized." -ForegroundColor Yellow
    $reinit = Read-Host "Do you want to reinitialize? (y/N)"
    if ($reinit -eq "y" -or $reinit -eq "Y") {
        Remove-Item -Recurse -Force .git
        git init
        Write-Host "Git reinitialized." -ForegroundColor Green
    }
} else {
    Write-Host "Initializing git repository..." -ForegroundColor Green
    git init
}

Write-Host ""
Write-Host "Adding files to git..." -ForegroundColor Green
git add .

Write-Host ""
Write-Host "Creating initial commit..." -ForegroundColor Green
git commit -m "Initial commit: Docker configuration for MSG Viewer"

Write-Host ""
Write-Host "Setting up remote..." -ForegroundColor Green
# Remove existing remote if it exists
git remote remove origin 2>$null
git remote add origin https://github.com/ngttech/msg-viewer-docker.git

Write-Host ""
Write-Host "Setting default branch to main..." -ForegroundColor Green
git branch -M main

Write-Host ""
Write-Host "Pushing to GitHub..." -ForegroundColor Green
git push -u origin main

Write-Host ""
Write-Host "Done! ✅" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Visit https://github.com/ngttech/msg-viewer-docker/actions" -ForegroundColor White
Write-Host "2. Watch the 'Build and Publish to GHCR' workflow run" -ForegroundColor White
Write-Host "3. Wait for it to complete (3-5 minutes)" -ForegroundColor White
Write-Host "4. Check for the image at https://github.com/orgs/ngttech/packages" -ForegroundColor White
Write-Host ""
