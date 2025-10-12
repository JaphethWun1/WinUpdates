# Power Settings Configuration Module

function Set-PowerSettings {
    Write-Host "Configuring power..."
    
    # Check for High Performance plan and activate it
    $highPerf = powercfg /list | Select-String "High performance"
    
    if (!$highPerf) {
        # Create High Performance plan from template
        $highPerfGuid = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
        $output = powercfg /duplicatescheme $highPerfGuid 2>&1
        
        if ($output -match "GUID: ([a-f0-9\-]+)") {
            powercfg /setactive $matches[1] 2>&1 | Out-Null
        }
    } else {
        # Activate existing High Performance plan
        if ($highPerf -match "GUID: ([a-f0-9\-]+)") {
            powercfg /setactive $matches[1] 2>&1 | Out-Null
        }
    }
    
    # Set all timeouts to 0 (never)
    powercfg /change monitor-timeout-ac 0 2>&1 | Out-Null
    powercfg /change monitor-timeout-dc 0 2>&1 | Out-Null
    powercfg /change standby-timeout-ac 0 2>&1 | Out-Null
    powercfg /change standby-timeout-dc 0 2>&1 | Out-Null
    powercfg /change disk-timeout-ac 0 2>&1 | Out-Null
    powercfg /change disk-timeout-dc 0 2>&1 | Out-Null
    
    Write-Host "Power configured"
}