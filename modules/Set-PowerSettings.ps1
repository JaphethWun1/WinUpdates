<#
.SYNOPSIS
    Power Settings Configuration Module
    
.DESCRIPTION
    Configures Windows power settings
    - Sets power plan to High Performance
    - Sets all timeouts to Never
#>

# ============================================
# POWER CONFIGURATION FUNCTION
# ============================================

function Set-PowerSettings {
    <#
    .SYNOPSIS
        Configures Windows power plan and timeout settings
    #>
    
    Write-Host "Configuring power..."
    
    # ----------------------------------------
    # Activate High Performance Power Plan
    # ----------------------------------------
    # High Performance GUID: 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    
    $highPerf = powercfg /list | Select-String "High performance"
    
    if (!$highPerf) {
        # High Performance plan doesn't exist, create it
        $highPerfGuid = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
        $output = powercfg /duplicatescheme $highPerfGuid 2>&1
        
        if ($output -match "GUID: ([a-f0-9\-]+)") {
            powercfg /setactive $matches[1] 2>&1 | Out-Null
        }
    } else {
        # High Performance plan exists, activate it
        if ($highPerf -match "GUID: ([a-f0-9\-]+)") {
            powercfg /setactive $matches[1] 2>&1 | Out-Null
        }
    }
    
    # ----------------------------------------
    # Set All Timeouts to Never (0)
    # ----------------------------------------
    # AC = Plugged in
    # DC = Battery
    
    # Display timeout
    powercfg /change monitor-timeout-ac 0 2>&1 | Out-Null
    powercfg /change monitor-timeout-dc 0 2>&1 | Out-Null
    
    # Sleep timeout
    powercfg /change standby-timeout-ac 0 2>&1 | Out-Null
    powercfg /change standby-timeout-dc 0 2>&1 | Out-Null
    
    # Disk timeout
    powercfg /change disk-timeout-ac 0 2>&1 | Out-Null
    powercfg /change disk-timeout-dc 0 2>&1 | Out-Null
    
    Write-Host "Power configured"
}