# Windows Update Module

function Install-WindowsUpdates {
    Write-Host "Checking for updates..."
    
    # Install PSWindowsUpdate module if needed
    if (!(Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        try {
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null
            Install-Module PSWindowsUpdate -Force -Confirm:$false | Out-Null
        } catch {
            Write-Host "Module install failed, using native method"
            Install-UpdatesNative
            return
        }
    }
    
    Import-Module PSWindowsUpdate
    
    # Get Security, Cumulative, and Driver updates only
    $updates = Get-WindowsUpdate | Where-Object {
        $_.Title -match "Security|Cumulative|Driver" -and 
        $_.Title -notmatch "Feature|Preview"
    }
    
    if ($updates.Count -eq 0) {
        Write-Host "No updates found"
        return
    }
    
    Write-Host "Found $($updates.Count) updates"
    
    # Download all updates
    Write-Host "Downloading..."
    Get-WindowsUpdate -Download -AcceptAll -IgnoreReboot -Title $updates.Title | Out-Null
    
    # Install all updates
    Write-Host "Installing..."
    Install-WindowsUpdate -AcceptAll -IgnoreReboot -Title $updates.Title | Out-Null
    
    Write-Host "Updates installed"
}

function Install-UpdatesNative {
    Write-Host "Using native Windows Update..."
    
    $session = New-Object -ComObject Microsoft.Update.Session
    $searcher = $session.CreateUpdateSearcher()
    
    Write-Host "Searching..."
    $result = $searcher.Search("IsInstalled=0 and Type='Software'")
    
    if ($result.Updates.Count -eq 0) {
        Write-Host "No updates found"
        return
    }
    
    $toDownload = New-Object -ComObject Microsoft.Update.UpdateColl
    $count = 0
    
    foreach ($update in $result.Updates) {
        $title = $update.Title.ToLower()
        if ($title -match "security|cumulative|driver" -and $title -notmatch "feature|preview") {
            $toDownload.Add($update) | Out-Null
            $count++
        }
    }
    
    if ($count -eq 0) {
        Write-Host "No applicable updates"
        return
    }
    
    Write-Host "Found $count updates"
    
    # Download phase
    Write-Host "Downloading..."
    $downloader = $session.CreateUpdateDownloader()
    $downloader.Updates = $toDownload
    $downloader.Download() | Out-Null
    
    # Install phase
    Write-Host "Installing..."
    $toInstall = New-Object -ComObject Microsoft.Update.UpdateColl
    foreach ($update in $toDownload) {
        if ($update.IsDownloaded) {
            $toInstall.Add($update) | Out-Null
        }
    }
    
    $installer = $session.CreateUpdateInstaller()
    $installer.Updates = $toInstall
    $installer.Install() | Out-Null
    
    Write-Host "Updates installed"
}# Windows Update Module (Download First, Then Install)

function Install-WindowsUpdates {
    Write-Host "→ Installing Windows Updates..." -ForegroundColor Yellow
    Write-Host "  (Security, Cumulative, and Drivers only)" -ForegroundColor Gray
    Write-Host ""
    
    # Try to use PSWindowsUpdate module
    if (!(Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Write-Host "  Installing PSWindowsUpdate module..." -ForegroundColor Cyan
        try {
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null
            Install-Module PSWindowsUpdate -Force -Confirm:$false | Out-Null
            Write-Host "    ✓ Module installed" -ForegroundColor Green
        } catch {
            Write-Host "    ✗ Module install failed, using native method" -ForegroundColor Yellow
            Install-UpdatesNative
            return
        }
    }
    
    Import-Module PSWindowsUpdate
    Write-Host "  Searching for updates..." -ForegroundColor Cyan
    
    # Only get Security, Cumulative, and Driver updates
    $updates = Get-WindowsUpdate | Where-Object {
        $_.Title -match "Security|Cumulative|Driver" -and 
        $_.Title -notmatch "Feature|Preview"
    }
    
    if ($updates.Count -eq 0) {
        Write-Host ""
        Write-Host "  ✓ No updates available" -ForegroundColor Green
        Write-Host ""
        return
    }
    
    Write-Host ""
    Write-Host "  Found $($updates.Count) updates:" -ForegroundColor Cyan
    foreach ($update in $updates) {
        Write-Host "    • $($update.Title)" -ForegroundColor Gray
    }
    
    # DOWNLOAD FIRST
    Write-Host ""
    Write-Host "  ⬇ Downloading all updates..." -ForegroundColor Cyan
    Get-WindowsUpdate -Download -AcceptAll -IgnoreReboot -Title $updates.Title | Out-Null
    Write-Host "    ✓ All downloads complete" -ForegroundColor Green
    
    # THEN INSTALL
    Write-Host ""
    Write-Host "  📦 Installing all updates..." -ForegroundColor Cyan
    Install-WindowsUpdate -AcceptAll -IgnoreReboot -Title $updates.Title | Out-Null
    
    Write-Host ""
    Write-Host "  ✓ Updates installed!" -ForegroundColor Green
    Write-Host ""
}

function Install-UpdatesNative {
    Write-Host "  Using native Windows Update..." -ForegroundColor Cyan
    
    $session = New-Object -ComObject Microsoft.Update.Session
    $searcher = $session.CreateUpdateSearcher()
    
    Write-Host "  Searching..." -ForegroundColor Gray
    $result = $searcher.Search("IsInstalled=0 and Type='Software'")
    
    if ($result.Updates.Count -eq 0) {
        Write-Host ""
        Write-Host "  ✓ No updates available" -ForegroundColor Green
        Write-Host ""
        return
    }
    
    $toDownload = New-Object -ComObject Microsoft.Update.UpdateColl
    $count = 0
    
    Write-Host ""
    Write-Host "  Filtering updates..." -ForegroundColor Cyan
    foreach ($update in $result.Updates) {
        $title = $update.Title.ToLower()
        if ($title -match "security|cumulative|driver" -and $title -notmatch "feature|preview") {
            Write-Host "    • $($update.Title)" -ForegroundColor Gray
            $toDownload.Add($update) | Out-Null
            $count++
        }
    }
    
    if ($count -eq 0) {
        Write-Host ""
        Write-Host "  ✓ No applicable updates" -ForegroundColor Green
        Write-Host ""
        return
    }
    
    # DOWNLOAD PHASE
    Write-Host ""
    Write-Host "  ⬇ Downloading $count updates..." -ForegroundColor Cyan
    $downloader = $session.CreateUpdateDownloader()
    $downloader.Updates = $toDownload
    $downloadResult = $downloader.Download()
    Write-Host "    ✓ All downloads complete" -ForegroundColor Green
    
    # INSTALL PHASE
    Write-Host ""
    Write-Host "  📦 Installing $count updates..." -ForegroundColor Cyan
    $toInstall = New-Object -ComObject Microsoft.Update.UpdateColl
    foreach ($update in $toDownload) {
        if ($update.IsDownloaded) {
            $toInstall.Add($update) | Out-Null
        }
    }
    
    $installer = $session.CreateUpdateInstaller()
    $installer.Updates = $toInstall
    $installer.Install() | Out-Null
    
    Write-Host ""
    Write-Host "  ✓ Updates installed!" -ForegroundColor Green
    Write-Host ""
}