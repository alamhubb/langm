# LangM Release Script
# Usage: npm run release

param(
    [string]$Version
)

$ErrorActionPreference = "Stop"

function Write-Info { Write-Host "[INFO] $args" -ForegroundColor Cyan }
function Write-Success { Write-Host "[OK] $args" -ForegroundColor Green }
function Write-Warn { Write-Host "[WARN] $args" -ForegroundColor Yellow }
function Write-Err { Write-Host "[ERROR] $args" -ForegroundColor Red }

Write-Host ""
Write-Host "=== LangM Release Tool ===" -ForegroundColor Magenta
Write-Host ""

# Check git status
Write-Info "Checking Git status..."
$status = git status --porcelain
if ($status) {
    Write-Err "Working directory is not clean. Please commit or stash changes first."
    Write-Host $status
    exit 1
}

# Ensure on main branch
$branch = git branch --show-current
if ($branch -ne "main" -and $branch -ne "master") {
    Write-Warn "Current branch: $branch (recommend releasing from main/master)"
    $confirm = Read-Host "Continue? (y/N)"
    if ($confirm -ne "y" -and $confirm -ne "Y") {
        exit 0
    }
}

# Get current version
$cargoToml = Get-Content "Cargo.toml" -Raw
if ($cargoToml -match 'version\s*=\s*"([^"]+)"') {
    $currentVersion = $matches[1]
    Write-Info "Current version: v$currentVersion"
} else {
    Write-Err "Cannot read version from Cargo.toml"
    exit 1
}

# Determine new version
if ($Version) {
    $newVersion = $Version -replace "^v", ""
} else {
    # Auto increment patch version
    $versionParts = $currentVersion -split "\."
    $major = [int]$versionParts[0]
    $minor = [int]$versionParts[1]
    $patch = [int]$versionParts[2] + 1
    $autoVersion = "$major.$minor.$patch"
    
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Gray
    Write-Host "  [Enter] Auto increment to $autoVersion" -ForegroundColor Gray
    Write-Host "  [s]     Stay at current version $currentVersion" -ForegroundColor Gray
    Write-Host "  [x.y.z] Custom version number" -ForegroundColor Gray
    Write-Host ""
    $input = Read-Host "Version"
    
    if ([string]::IsNullOrWhiteSpace($input)) {
        $newVersion = $autoVersion
    } elseif ($input -eq "s" -or $input -eq "S") {
        $newVersion = $currentVersion
    } else {
        $newVersion = $input
    }
}

$tag = "v$newVersion"
Write-Info "Will release version: $tag"

# Check if tag exists
$existingTag = git tag -l $tag
if ($existingTag) {
    Write-Warn "Tag $tag already exists"
    $confirm = Read-Host "Delete and recreate? (y/N)"
    if ($confirm -eq "y" -or $confirm -eq "Y") {
        git tag -d $tag 2>$null
        git push origin --delete $tag 2>$null
        Write-Info "Deleted old tag"
    } else {
        Write-Err "Release cancelled"
        exit 1
    }
}

# Update version if needed
if ($newVersion -ne $currentVersion) {
    Write-Info "Updating Cargo.toml version..."
    $cargoToml = $cargoToml -replace '(version\s*=\s*")[^"]+(")', "`${1}$newVersion`${2}"
    Set-Content "Cargo.toml" $cargoToml -NoNewline
    
    Write-Info "Updating package.json version..."
    $packageJson = Get-Content "package.json" -Raw | ConvertFrom-Json
    $packageJson.version = $newVersion
    $packageJson | ConvertTo-Json -Depth 10 | Set-Content "package.json"
    
    Write-Info "Syncing Cargo.lock..."
    $ErrorActionPreference = "Continue"
    cargo check *>&1 | Out-Null
    $ErrorActionPreference = "Stop"
    
    git add Cargo.toml Cargo.lock package.json
    git commit -m "chore: bump version to $newVersion"
    Write-Success "Version updated"
}

# Create tag
Write-Info "Creating Git tag..."
git tag -a $tag -m "Release $tag"
Write-Success "Tag $tag created"

# Check for github remote
$githubRemote = git remote -v | Select-String "github.com" | Select-Object -First 1
if ($githubRemote -match "^(\S+)") {
    $githubRemoteName = $matches[1]
} else {
    $githubRemoteName = $null
}

# Push confirmation
Write-Host ""
Write-Host "Will execute:" -ForegroundColor Yellow
Write-Host "  1. Push code to GitHub (triggers Cirrus CI)" -ForegroundColor Gray
Write-Host "  2. Push tag $tag" -ForegroundColor Gray
Write-Host "  3. Cirrus CI auto build (~10-15 min)" -ForegroundColor Gray
Write-Host "  4. Download artifacts and create GitHub Release manually" -ForegroundColor Gray
Write-Host ""
Write-Host "Press Enter to continue, Ctrl+C to cancel" -ForegroundColor Gray
Read-Host | Out-Null

# Push to GitHub (triggers Cirrus CI)
if ($githubRemoteName) {
    Write-Info "Pushing to GitHub ($githubRemoteName)..."
    git push $githubRemoteName $branch
    git push $githubRemoteName $tag
} else {
    Write-Warn "No GitHub remote found, pushing to origin..."
    git push origin $branch
    git push origin $tag
}

# Also sync to Gitee if origin is different
if ($githubRemoteName -and $githubRemoteName -ne "origin") {
    Write-Info "Syncing to Gitee (origin)..."
    git push origin $branch 2>&1 | Out-Null
    git push origin $tag 2>&1 | Out-Null
}

Write-Host ""
Write-Success "Release triggered!"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Wait for Cirrus CI build (~10-15 min)" -ForegroundColor Gray
Write-Host "  2. Download artifacts from Cirrus CI" -ForegroundColor Gray
Write-Host "  3. Create GitHub Release and upload files" -ForegroundColor Gray
Write-Host ""
Write-Host "Links:" -ForegroundColor Yellow
Write-Host "  Cirrus CI:  https://cirrus-ci.com/github/alamhubb/langm" -ForegroundColor Cyan
Write-Host "  Create Release: https://github.com/alamhubb/langm/releases/new?tag=$tag" -ForegroundColor Cyan
Write-Host ""
