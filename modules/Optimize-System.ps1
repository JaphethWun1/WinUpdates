# System Optimization Module

function Optimize-System {
    Write-Host "Optimizing system..."
    
    # Clean temp files
    $tempPaths = @("$env:TEMP\*", "C:\Windows\Temp\*")
    $cleaned = 0
    foreach ($path in $tempPaths) {
        $items = Get-ChildItem -Path $path -Force -ErrorAction SilentlyContinue
        $cleaned += $items.Count
        Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    }
    
    # Run disk cleanup
    Start-Process cleanmgr.exe -ArgumentList "/sagerun:1" -WindowStyle Hidden -Wait -ErrorAction SilentlyContinue
    
    Write-Host "Cleaned $cleaned items"
}