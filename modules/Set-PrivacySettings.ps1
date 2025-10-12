# Privacy Settings Configuration Module

function Set-PrivacySettings {
    Write-Host "→ Configuring Privacy Settings..." -ForegroundColor Yellow
    Write-Host ""
    
    # Disable tracking services only
    Write-Host "  Disabling tracking services..." -ForegroundColor Cyan
    
    $trackingServices = @(
        "DiagTrack"          # Tracking telemetry (not needed for diagnostics)
        "dmwappushservice"   # WAP Push routing
    )
    
    foreach ($svc in $trackingServices) {
        try {
            Stop-Service $svc -Force
            Set-Service $svc -StartupType Disabled
            Write-Host "    ✓ Disabled: $svc" -ForegroundColor Green
        } catch {
            Write-Host "    ✗ Failed: $svc" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "  Keeping diagnostic services enabled..." -ForegroundColor Cyan
    
    # Ensure diagnostic services stay enabled for troubleshooting
    $diagnosticServices = @(
        "DPS"                # Diagnostic Policy Service (network diagnostics)
        "WdiServiceHost"     # Diagnostic Service Host
        "WdiSystemHost"      # Diagnostic System Host
        "diagsvc"            # Diagnostic Execution Service
        "TroubleshootingSvc" # Troubleshooting Service
    )
    
    foreach ($svc in $diagnosticServices) {
        try {
            Set-Service $svc -StartupType Manual -ErrorAction SilentlyContinue
            Write-Host "    ✓ Available: $svc" -ForegroundColor Green
        } catch {}
    }
    
    Write-Host ""
    Write-Host "  Configuring telemetry..." -ForegroundColor Cyan
    
    # Set telemetry to Basic (allows diagnostics, limits tracking)
    $telemetryPaths = @(
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
    )
    
    foreach ($path in $telemetryPaths) {
        if (!(Test-Path $path)) {
            New-Item -Path $path -Force -ErrorAction SilentlyContinue | Out-Null
        }
        Set-ItemProperty -Path $path -Name "AllowTelemetry" -Type DWord -Value 1 -ErrorAction SilentlyContinue | Out-Null
    }
    Write-Host "    ✓ Telemetry: Basic (diagnostics work)" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "  Configuring Windows Update..." -ForegroundColor Cyan
    
    # Enable P2P updates on local network only
    $doPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config"
    if (!(Test-Path $doPath)) {
        New-Item -Path $doPath -Force -ErrorAction SilentlyContinue | Out-Null
    }
    Set-ItemProperty -Path $doPath -Name "DODownloadMode" -Type DWord -Value 1 -ErrorAction SilentlyContinue | Out-Null
    Write-Host "    ✓ P2P updates: LAN only" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "  ✓ Privacy configuration complete!" -ForegroundColor Green
    Write-Host ""
}