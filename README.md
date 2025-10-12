# Windows Debloat & Update Script

A modular PowerShell script to debloat, configure privacy settings, and update Windows systems.
Designed for Windows Audit Mode (Ctrl+Shift+F3).

## Features

- **Power Settings**: Sets High Performance mode and display/sleep timeouts to Never
- **Bloatware Removal**: Removes pre-installed unwanted apps (keeps GetHelp, YourPhone, WindowsSoundRecorder, WindowsFeedbackHub)
- **Privacy Configuration**: Disables tracking while keeping diagnostics and location services
- **Notifications**: Disabled (calendar remains accessible)
- **Windows Updates**: Downloads then installs Security, Cumulative, and Driver updates
- **System Optimization**: Cleans temp files and runs disk cleanup
- **LAN Updates**: Enables Windows Update P2P on local network only
- **Concurrent Execution**: All setup tasks run in parallel for faster completion
- **Multi-Cycle Updates**: Automatically restarts and re-updates to catch all updates

## Quick Start

### Run directly from GitHub:

```powershell
irm https://raw.githubusercontent.com/yourusername/yourrepo/main/debloat.ps1 | iex
```

**To change update cycles:** Edit `$UpdateCycles` at the top of `debloat.ps1` (default is 3)

### Download and run locally:

```powershell
# Download
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/yourusername/yourrepo/main/debloat.ps1" -OutFile "debloat.ps1"

# Run
.\debloat.ps1
```

## Configuration

Edit variables at the top of `debloat.ps1`:

```powershell
$UpdateCycles = 3  # Number of update-restart cycles

$SkipUpdates = $false
$SkipDebloat = $false
$SkipPrivacy = $false
$SkipOptimization = $false
$SkipPowerSettings = $false
```

## How It Works

### Concurrent Execution
All setup tasks run in parallel:
- Power settings configuration
- Bloatware removal
- Privacy configuration  
- System optimization

### Update Process
1. **Download Phase**: All updates downloaded first
2. **Install Phase**: All updates installed together
3. **Restart**: Automatic restart after each cycle
4. **Repeat**: Continues for configured number of cycles

### Update Cycles
1. **First Run**: Setup tasks + first update
2. **After Restart**: Automatically runs next update cycle
3. **Repeats**: Until all cycles complete
4. **Final**: Shows completion message

## Repository Structure

```
.
├── debloat.ps1                      # Main script
├── modules/
│   ├── Set-PowerSettings.ps1        # Power configuration
│   ├── Remove-Bloatware.ps1         # Bloatware removal
│   ├── Set-PrivacySettings.ps1      # Privacy & notifications
│   ├── Install-WindowsUpdates.ps1   # Windows updates
│   └── Optimize-System.ps1          # System cleanup
├── config/
│   └── bloatware-list.txt           # Bloatware list
└── README.md
```

## What Gets Modified

### Power Settings
- Power plan: High Performance
- Display timeout: Never (AC and Battery)
- Sleep timeout: Never (AC and Battery)
- Disk timeout: Never

### Bloatware Removal
- Removes Xbox, Bing, games, and promotional apps
- Removes third-party bloatware
- **Keeps**: GetHelp, YourPhone, WindowsSoundRecorder, WindowsFeedbackHub

### Privacy Settings
- **Tracking**: Disabled (DiagTrack service)
- **Diagnostics**: Enabled (for troubleshooting)
- **Telemetry**: Basic level (allows diagnostics)
- **Location**: Unchanged (enabled)
- **P2P Updates**: LAN only
- **Notifications**: Disabled (calendar still works)

### Windows Updates
- Security updates: Yes
- Cumulative updates: Yes
- Driver updates: Yes
- Feature updates: No
- Preview updates: No

### System Optimization
- Cleans temporary files
- Runs disk cleanup utility

## Requirements

- Windows 10 or Windows 11
- PowerShell 5.1 or later
- Administrator privileges
- Internet connection

## Troubleshooting

### Script execution error
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Updates not found
Ensure Windows Update service is running:
```powershell
Start-Service wuauserv
```

### Module errors
PSWindowsUpdate module will auto-install, or script falls back to native Windows Update

## License

MIT License

## Disclaimer

This script modifies system settings. Use at your own risk. Always ensure you have backups.r completion
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
