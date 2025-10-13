<#
.SYNOPSIS
    System Optimization Module
    
.DESCRIPTION
    Cleans temporary files and runs disk cleanup
#>

# ============================================
# OPTIMIZATION FUNCTION
# ============================================

function Optimize-System {
    <#
    .SYNOPSIS
        Cleans temporary files and optimizes system
    #>
    
    Write-Host "Optimizing system..."
    
    # ----------------------------------------
    # Clean Temporary Files
    # ----------------------------------------
    $tempPaths = @(
        "$env:TEMP\*"           # User temp folder
        "C:\Windows\Temp\*"     # System temp folder
    )
    
    $cleaned = 0
    foreach ($path in $tempPaths) {
        $items = Get-ChildItem -Path $path -Force -ErrorAction SilentlyContinue
        $cleaned += $items.Count
        Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    }
    
    # ----------------------------------------
    # Run Disk Cleanup
    # ----------------------------------------
    # /sagerun:1 runs disk cleanup silently with preset options
    Start-Process cleanmgr.exe -ArgumentList "/sagerun:1" -WindowStyle Hidden -Wait -ErrorAction SilentlyContinue
    
    Write-Host "Cleaned $cleaned items"
}