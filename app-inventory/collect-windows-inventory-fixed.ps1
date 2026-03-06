# Collect Windows App Inventory for Fresh Start (Fixed for Chinese Characters)
# Run this in PowerShell (Run as normal user, not Administrator unless needed)

# Set console encoding to UTF-8 to handle Chinese characters
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

Write-Host "=== Collecting Windows App Inventory (Fixed for Chinese) ===" -ForegroundColor Cyan

# Create output directory
$outputDir = "$env:USERPROFILE\Desktop\windows-app-inventory-fixed"
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}
Write-Host "Output directory: $outputDir" -ForegroundColor Green

# 1. Get installed Windows apps (Add/Remove Programs - x64 and x86)
Write-Host "`n1. Collecting installed Windows programs..." -ForegroundColor Yellow
$uninstallPaths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
)
$allApps = @()
foreach ($path in $uninstallPaths) {
    if (Test-Path $path) {
        $apps = Get-ItemProperty -Path "$path\*" | 
                Where-Object { $_.DisplayName -and $_.DisplayName -ne "" } |
                Select-Object DisplayName, DisplayVersion, Publisher, InstallDate
        $allApps += $apps
    }
}
# Save as both text (UTF-8 with BOM) and CSV for better compatibility
$allApps | Sort-Object DisplayName | Format-Table -AutoSize | Out-File -FilePath "$outputDir\windows-installed-programs.txt" -Encoding UTF8
$allApps | Sort-Object DisplayName | Export-Csv -Path "$outputDir\windows-installed-programs.csv" -NoTypeInformation -Encoding UTF8
Write-Host "   Saved to: windows-installed-programs.txt and windows-installed-programs.csv" -ForegroundColor Green

# 2. Get winget packages
Write-Host "`n2. Collecting winget packages..." -ForegroundColor Yellow
if (Get-Command winget -ErrorAction SilentlyContinue) {
    winget list --accept-source-agreements | Out-File -FilePath "$outputDir\winget-packages.txt" -Encoding UTF8
    Write-Host "   Saved to: winget-packages.txt" -ForegroundColor Green
} else {
    Write-Host "   winget not found, skipping" -ForegroundColor Red
}

# 3. Get Windows pip packages
Write-Host "`n3. Collecting Windows pip packages..." -ForegroundColor Yellow
$pipCmds = @("pip", "pip3", "py -m pip", "py3 -m pip")
foreach ($cmd in $pipCmds) {
    try {
        $output = & cmd /c "$cmd list --format=freeze 2>&1"
        if ($LASTEXITCODE -eq 0 -and $output) {
            $output | Out-File -FilePath "$outputDir\windows-pip-packages.txt" -Encoding UTF8
            Write-Host "   Saved to: windows-pip-packages.txt (using: $cmd)" -ForegroundColor Green
            break
        }
    } catch {}
}
if (-not (Test-Path "$outputDir\windows-pip-packages.txt")) {
    Write-Host "   No Windows pip found or no packages, skipping" -ForegroundColor Red
}

# 4. Get Windows npm packages (global)
Write-Host "`n4. Collecting Windows npm global packages..." -ForegroundColor Yellow
if (Get-Command npm -ErrorAction SilentlyContinue) {
    npm list -g --depth=0 | Out-File -FilePath "$outputDir\windows-npm-global.txt" -Encoding UTF8
    Write-Host "   Saved to: windows-npm-global.txt" -ForegroundColor Green
} else {
    Write-Host "   npm not found, skipping" -ForegroundColor Red
}

Write-Host "`n=== Done! ===" -ForegroundColor Cyan
Write-Host "Inventory saved to: $outputDir" -ForegroundColor Green
Write-Host "Note: windows-installed-programs.csv will show Chinese characters correctly in Excel/LibreOffice" -ForegroundColor Yellow
Write-Host "Please copy the contents of this folder to: \\wsl$\Ubuntu\home\qq\.openclaw\workspace\app-inventory\" -ForegroundColor Yellow
