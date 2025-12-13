# Release script - auto bump version, commit, tag and push

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("patch", "minor", "major")]
    [string]$BumpType = "patch"
)

$cargoContent = Get-Content "Cargo.toml" -Raw
if ($cargoContent -match 'version\s*=\s*"([^"]+)"') {
    $currentVersion = $matches[1]
} else {
    Write-Host "Error: Cannot read version from Cargo.toml" -ForegroundColor Red
    exit 1
}

$versionParts = $currentVersion.Split('.')
$major = [int]$versionParts[0]
$minor = [int]$versionParts[1]
$patch = [int]$versionParts[2]

switch ($BumpType) {
    "major" { $major++; $minor = 0; $patch = 0 }
    "minor" { $minor++; $patch = 0 }
    "patch" { $patch++ }
}

$newVersion = "$major.$minor.$patch"
$tag = "v$newVersion"

Write-Host "Version: $currentVersion -> $newVersion" -ForegroundColor Cyan

$newVersionStr = 'version = "' + $newVersion + '"'
$cargoContent = $cargoContent -replace 'version\s*=\s*"[^"]+"', $newVersionStr
Set-Content "Cargo.toml" $cargoContent -NoNewline

$pkgPath = "package.json"
if (Test-Path $pkgPath) {
    $pkgContent = Get-Content $pkgPath -Raw
    $newPkgVersionStr = '"version": "' + $newVersion + '"'
    $pkgContent = $pkgContent -replace '"version"\s*:\s*"[^"]+"', $newPkgVersionStr
    Set-Content $pkgPath $pkgContent -NoNewline
}

$docsPkgPath = "docs/package.json"
if (Test-Path $docsPkgPath) {
    $docsPkgContent = Get-Content $docsPkgPath -Raw
    $newDocsPkgVersionStr = '"version": "' + $newVersion + '"'
    $docsPkgContent = $docsPkgContent -replace '"version"\s*:\s*"[^"]+"', $newDocsPkgVersionStr
    Set-Content $docsPkgPath $docsPkgContent -NoNewline
}

Write-Host "Version updated" -ForegroundColor Green

Write-Host "Committing..." -ForegroundColor Yellow
git add Cargo.toml package.json docs/package.json
git commit -m "chore: bump version to $newVersion"

Write-Host "Creating tag: $tag" -ForegroundColor Yellow
git tag $tag

Write-Host "Pushing..." -ForegroundColor Yellow
git push
git push origin $tag

Write-Host ""
Write-Host "Release success! Version $tag" -ForegroundColor Green
Write-Host "  GitHub Actions building:" -ForegroundColor Green
Write-Host "  https://github.com/alamhubb/langm/actions" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Download after build:" -ForegroundColor Green
Write-Host "  https://github.com/alamhubb/langm/releases/tag/$tag" -ForegroundColor Cyan
