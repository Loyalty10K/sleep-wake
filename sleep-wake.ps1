
$saveFile = "$env:USERPROFILE\sleep-apps.json"
 
$criticalSafeList = @(
    "System","Idle","Registry","smss","csrss","wininit","winlogon",
    "services","lsass","svchost","fontdrvhost","dwm","spoolsv",
    "audiodg","SearchIndexer"
)
 
Write-Host "Command: sleep/wake"
$command = Read-Host ">"
 
if ($command -eq "sleep") {
    Write-Host "Saving and closing open applications..."
 
    $currentPid = $PID
 
    $apps = Get-Process | Where-Object {
        $_.MainWindowHandle -ne 0 -and
        $_.Id -ne $currentPid -and
        $criticalSafeList -notcontains $_.ProcessName
    }
 
    $appsToSave = @()
 
    foreach ($app in $apps) {
        try {
            $path = $app.Path
 
            if ($path) {
                $appsToSave += [PSCustomObject]@{
                    Name = $app.ProcessName
                    Path = $path
                }
            }
 
            Write-Host "Closing: $($app.ProcessName)"
            $app.CloseMainWindow() | Out-Null
        } catch {
            Write-Host "Could not close: $($app.ProcessName)"
        }
    }
 
    $appsToSave |
        Sort-Object Path -Unique |
        ConvertTo-Json |
        Set-Content $saveFile
 
    Start-Sleep -Seconds 3
 
    foreach ($app in $apps) {
        try {
            if (-not $app.HasExited) {
                Write-Host "Force closing: $($app.ProcessName)"
                Stop-Process -Id $app.Id -Force
            }
        } catch {}
    }
 
    Write-Host "Saved and closed."
 
    $shutdownChoice = Read-Host "Do you want to shut down the PC? yes/no"
 
    if ($shutdownChoice -eq "yes") {
        Write-Host "Shutting down the PC safely..."
        shutdown /s /t 0
    }
    else {
        Write-Host "Okay, PC stays on. Closing script."
        Start-Sleep -Seconds 1
        exit
    }
}
 
elseif ($command -eq "wake") {
    if (-not (Test-Path $saveFile)) {
        Write-Host "No saved applications found."
        Start-Sleep -Seconds 2
        exit
    }
 
    Write-Host "Waking applications..."
 
    $savedApps = Get-Content $saveFile | ConvertFrom-Json
 
    foreach ($app in $savedApps) {
        try {
            if (Test-Path $app.Path) {
                Write-Host "Opening: $($app.Name)"
                Start-Process $app.Path
                Start-Sleep -Milliseconds 400
            }
        } catch {
            Write-Host "Could not open: $($app.Name)"
        }
    }
 
    Write-Host "Done. Closing script."
    Start-Sleep -Seconds 1
    exit
}
 
else {
    Write-Host "Unknown command."
    Start-Sleep -Seconds 2
    exit
}
 






