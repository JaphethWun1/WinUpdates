# Bloatware Removal Module
# Keeps: GetHelp, YourPhone, WindowsSoundRecorder, WindowsFeedbackHub

$BloatwareApps = @(
    "Microsoft.BingNews"
    "Microsoft.BingWeather"
    "Microsoft.Getstarted"
    "Microsoft.Microsoft3DViewer"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.MixedReality.Portal"
    "Microsoft.People"
    "Microsoft.SkypeApp"
    "Microsoft.Wallet"
    "Microsoft.Xbox.TCUI"
    "Microsoft.XboxApp"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxGamingOverlay"
    "Microsoft.XboxIdentityProvider"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
    "Microsoft.WindowsMaps"
    "*Candy*"
    "*Disney*"
    "*Facebook*"
    "*Netflix*"
    "*Spotify*"
    "*Twitter*"
    "*TikTok*"
)

function Remove-Bloatware {
    Write-Host "Removing bloatware..."
    
    $removed = 0
    
    foreach ($app in $BloatwareApps) {
        # Remove for current user
        $packages = Get-AppxPackage -Name $app -ErrorAction SilentlyContinue
        foreach ($pkg in $packages) {
            Remove-AppxPackage -Package $pkg.PackageFullName -ErrorAction SilentlyContinue | Out-Null
            $removed++
        }
        
        # Remove for all users
        $allUserPackages = Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue
        foreach ($pkg in $allUserPackages) {
            Remove-AppxPackage -Package $pkg.PackageFullName -AllUsers -ErrorAction SilentlyContinue | Out-Null
        }
        
        # Remove provisioned packages
        $provPkgs = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object DisplayName -like $app
        foreach ($pkg in $provPkgs) {
            Remove-AppxProvisionedPackage -Online -PackageName $pkg.PackageName -ErrorAction SilentlyContinue | Out-Null
        }
    }
    
    Write-Host "Removed $removed apps"
}