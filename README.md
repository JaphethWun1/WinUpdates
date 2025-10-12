# WinUpdates
# Windows Debloat & Update Script

A modular PowerShell script to debloat, configure privacy settings, and update Windows systems.

## Features

- **Power Settings**: Sets High Performance mode and display/sleep timeouts to Never
- **Bloatware Removal**: Removes pre-installed unwanted apps
- **Privacy Configuration**: Disables tracking while keeping diagnostics and location services
- **Windows Updates**: Downloads then installs Security, Cumulative, and Driver updates
- **System Optimization**: Cleans temp files and runs disk cleanup
- **LAN Updates**: Enables Windows Update P2P on local network
- **Concurrent Execution**: All setup tasks run in parallel for faster completion
- **Multi-Cycle Updates**: Automatically restarts and re-updates to catch all updates

## Quick Start

### Run directly from GitHub (One-liner):

```powershell
irm https://raw.githubusercontent.com/yourusername/yourrepo/main/debloat.ps1 | iex
```

**To change update cycles:** Edit the `$UpdateCycles` variable at the top of `debloat.ps1` on GitHub (default is 3)

### Download and run locally:

```powershell
# Download the script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/yourusername/yourrepo/main/debloat.ps1" -OutFile "debloat.ps1"

# Run with administrator privileges
.\debloat.ps1
```

## Usage Options

### Run all modules with 3 update cycles (default):
```powershell
.\debloat.ps1
```

### Change configuration:
Edit the variables at the top of `debloat.ps1`:
```powershell
$UpdateCycles = 5  # Change to 5 cycles
$SkipDebloat = $true  # Skip bloatware removal
```

### Or use parameters locally:
```powershell
# Skip Windows Updates
.\debloat.ps1 -SkipUpdates

# Skip Bloatware Removal
.\debloat.ps1 -SkipDebloat

# Skip Privacy Configuration
.\debloat.ps1 -SkipPrivacy

# Skip System Optimization
.\debloat.ps1 -SkipOptimization

# Skip Power Settings
.\debloat.ps1 -SkipPowerSettings

# Combine multiple skips
.\debloat.ps1 -SkipUpdates -SkipOptimization
```

## How It Works

### Concurrent Execution
All setup tasks run in **parallel** using PowerShell background jobs:
- Power settings configuration
- Bloatware removal
- Privacy configuration  
- System optimization

This significantly reduces total execution time!

### Update Process
1. **Download Phase**: All updates downloaded first
2. **Install Phase**: All updates installed together
3. This is faster than download-install-download-install cycles

### Update Cycles
The script automatically handles multiple update-restart cycles:

1. **First Run**: Debloat, privacy config, optimization, then first update
2. **After Restart**: Automatically runs again for next update cycle
3. **Repeats**: Continues until all cycles complete (default: 3 cycles)
4. **Final**: Cleans up and finishes

This ensures you don't miss updates that only appear after previous updates are installed.

**Change cycles**: Use `-UpdateCycles <number>` parameter (default is 3)

```
.
├── debloat.ps1                      # Main script (runs tasks concurrently)
├── modules/
│   ├── Set-PowerSettings.ps1        # Power plan and timeout configuration
│   ├── Remove-Bloatware.ps1         # Bloatware removal module
│   ├── Set-PrivacySettings.ps1      # Privacy configuration module
│   ├── Install-WindowsUpdates.ps1   # Windows Update module (download then install)
│   └── Optimize-System.ps1          # System optimization module
├── config/
│   └── bloatware-list.txt           # Configurable bloatware list
└── README.md
```

## What Gets Modified

### Power Settings
- ✅ Sets power plan to High Performance (creates it if missing)
- ✅ Display timeout: Never (AC and Battery)
- ✅ Sleep timeout: Never (AC and Battery)
- ✅ Hard disk timeout: Never

### Bloatware Removal
- Removes Xbox apps, built-in games, and promotional apps
- Removes third-party bloatware (Candy Crush, Netflix, etc.)
- Can be customized via `config/bloatware-list.txt`

### Privacy Settings
- ✅ **Keeps Diagnostics Enabled** (set to Basic level)
- ✅ **Keeps Location Services Enabled**
- ❌ Disables DiagTrack (tracking service)
- ❌ Disables WAP Push Message Routing
- ✅ Enables Windows Update P2P on LAN only

### Windows Updates
- ✅ Installs Security updates
- ✅ Installs Cumulative updates
- ✅ Installs Driver updates
- ❌ Skips Feature updates
- ❌ Skips Preview updates

### System Optimization
- Cleans temporary files
- Runs Windows disk cleanup utility

## Requirements

- Windows 10 or Windows 11
- PowerShell 5.1 or later
- Administrator privileges
- Internet connection

## Customization

### Modify Bloatware List

Edit `config/bloatware-list.txt` to add or remove apps from the removal list.

### Modify Privacy Settings

Edit `modules/Set-PrivacySettings.ps1` to adjust telemetry levels or other privacy settings.

## Safety

- Script includes error handling and fallbacks
- No system-critical apps are removed
- Creates restore points (when applicable)
- Prompts before restart

## Troubleshooting

### "Script cannot be loaded" error
Enable script execution:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### PSWindowsUpdate module fails
The script includes a fallback to native Windows Update COM interface.

### Updates not installing
Ensure Windows Update service is running:
```powershell
Start-Service wuauserv
```

## Contributing

Feel free to submit issues or pull requests to improve the script!

## License

MIT License - Feel free to modify and distribute

## Disclaimer

This script modifies system settings. Use at your own risk. Always ensure you have backups before running system modification scripts.