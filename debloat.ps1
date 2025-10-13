#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Windows Debloat and Update Script
    
.DESCRIPTION
    Automated script for Windows Audit Mode (Ctrl+Shift+F3)
    - Configures power settings to High Performance
    - Removes bloatware applications
    - Disables tracking, keeps diagnostics enabled
    - Disables notifications, keeps calendar accessible
    - Downloads and installs Security/Cumulative/Driver updates
    - Automatically restarts and continues update cycles
    
.NOTES
    Author: Your Name
    Repository: https://github.com/JaphethWun1/WinUpdates
    Run: irm https://raw.githubusercontent.com/JaphethWun1/WinUpdates/main/debloat.ps1 | iex
#>

# ============================================
# CONFIGURATION - Edit these settings
# ============================================

# Number of update-restart cycles (3 recommended)
$UpdateCycles = 3

# Skip specific tasks (set to $true to skip)
$SkipUpdates = $false
$SkipDebloat = $false
$SkipPrivacy = $false
$SkipOptimization = $false
$SkipPowerSettings = $false

# ============================================
# SCRIPT SETTINGS - Do not edit below
# ============================================

$ErrorActionPreference = "SilentlyContinue"
$ProgressPreference = "SilentlyContinue"

# GitHub repository URL for modules
$repoUrl = "https://raw.githubusercontent.com/JaphethWun1/WinUpdates/main"

# Registry path for tracking update cycles
$regPath = "HKLM:\SOFTWARE\WindowsDebloatScript"
$cycleKey = "UpdateCycle"

# ============================================
# HELPER FUNCTIONS
# ============================================

function Get-CurrentCycle {
    <#
    .SYNOPSIS
        Gets the current update cycle number from registry
    #>
    if (!(Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
        Set-ItemProperty -Path $regPath -Name $cycleKey -Value 0
        return 0
    }
    
    $cycle = Get-ItemProperty -Path $regPath -Name $cycleKey -ErrorAction SilentlyContinue
    if ($null -eq $cycle) { return 0 }
    return $cycle.$cycleKey
}

function Set-CurrentCycle {
    <#
    .SYNOPSIS
        Saves the current update cycle number to registry
    #>
    param([int]$Cycle)
    
    if (!(Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    Set-ItemProperty -Path $regPath -Name $cycleKey -Value $Cycle
}

function Clear-CycleTracking {
    <#
    .SYNOPSIS
        Removes cycle tracking from registry
    #>
    if (Test-Path $regPath) {
        Remove-Item -Path $regPath -Force
    }
}

function Start-ConcurrentTasks {
    <#
    .SYNOPSIS
        Runs all setup tasks in parallel using background jobs
    #>
    $jobs = @()
    
    # Power settings job
    if (!$SkipPowerSettings) {
        $jobs += Start-Job -ScriptBlock {
            $script = Invoke-RestMethod "$using:repoUrl/modules/Set-PowerSettings.ps1"
            Invoke-Expression $script
            Set-PowerSettings
        }
    }
    
    # Bloatware removal job
    if (!$SkipDebloat) {
        $jobs += Start-Job -ScriptBlock {
            $script = Invoke-RestMethod "$using:repoUrl/modules/Remove-Bloatware.ps1"
            Invoke-Expression $script
            Remove-Bloatware
        }
    }
    
    # Privacy configuration job
    if (!$SkipPrivacy) {
        $jobs += Start-Job -ScriptBlock {
            $script = Invoke-RestMethod "$using:repoUrl/modules/Set-PrivacySettings.ps1"
            Invoke-Expression $script
            Set-PrivacySettings
        }
    }
    
    # System optimization job
    if (!$SkipOptimization) {
        $jobs += Start-Job -ScriptBlock {
            $script = Invoke-RestMethod "$using:repoUrl/modules/Optimize-System.ps1"
            Invoke-Expression $script
            Optimize-System
        }
    }
    
    # Wait for all jobs to complete and display output
    foreach ($job in $jobs) {
        $result = Receive-Job -Job $job -Wait
        Write-Host $result
    }
    
    # Clean up completed jobs
    $jobs | Remove-Job
}

function Install-AllUpdates {
    <#
    .SYNOPSIS
        Downloads and installs Windows updates
    #>
    $script = Invoke-RestMethod "$repoUrl/modules/Install-WindowsUpdates.ps1"
    Invoke-Expression $script
    Install-WindowsUpdates
}

# ============================================
# MAIN EXECUTION
# ============================================

$currentCycle = Get-CurrentCycle

# Display header with current stage
Write-Host ""
Write-Host "========================================="
Write-Host " Windows Debloat & Update"
if ($currentCycle -gt 0) { 
    Write-Host " Stage: $currentCycle of $UpdateCycles" 
}
Write-Host "========================================="
Write-Host ""

# First run only - execute setup tasks
if ($currentCycle -eq 0) {
    Write-Host "Running setup tasks..."
    Start-ConcurrentTasks
    Write-Host "Setup complete"
    Write-Host ""
}

# Update cycle execution
if (!$SkipUpdates) {
    Write-Host "Update Stage: $($currentCycle + 1) of $UpdateCycles"
    Write-Host ""
    
    # Run updates
    Install-AllUpdates
    
    # Increment cycle counter
    $currentCycle++
    Set-CurrentCycle $currentCycle
    
    # Check if more cycles are needed
    if ($currentCycle -lt $UpdateCycles) {
        # More cycles needed - schedule restart
        Write-Host ""
        Write-Host "Restarting for Stage $($currentCycle + 1)..."
        Write-Host ""
        
        # Create scheduled task to run after restart
        $scriptPath = $MyInvocation.MyCommand.Path
        if ($scriptPath) {
            $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
            $trigger = New-ScheduledTaskTrigger -AtLogOn
            $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
            Register-ScheduledTask -TaskName "WindowsDebloatUpdate" -Action $action -Trigger $trigger -Principal $principal -Force | Out-Null
        }
        
        Start-Sleep -Seconds 3
        Restart-Computer -Force
        exit
        
    } else {
        # All cycles complete
        Clear-CycleTracking
        Unregister-ScheduledTask -TaskName "WindowsDebloatUpdate" -Confirm:$false -ErrorAction SilentlyContinue
        
        Write-Host ""
        Write-Host "========================================="
        Write-Host " COMPLETED"
        Write-Host " All $UpdateCycles stages finished"
        Write-Host "========================================="
        Write-Host ""
        Write-Host "Press any key to exit..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
    
} else {
    # Updates skipped
    Clear-CycleTracking
    Write-Host ""
    Write-Host "========================================="
    Write-Host " COMPLETED"
    Write-Host "========================================="
    Write-Host ""
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}