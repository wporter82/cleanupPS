<#
.SYNOPSIS
    Cleans a directory of files older than a period of days
.DESCRIPTION
    Cleans a directory of files and folders that are older than a specified number of days.
    Default values can be modified in the file or they can be passed as command line arguments.
.PARAMETER filePath
    Location that the cleanup will be done.
.PARAMETER limit
    The total size in GB that the target file path should be before cleaning is done.
.PARAMETER days
    How many days back files should be kept. Any file older will be deleted.
.PARAMETER logFile
    Location of the generated log file.
    Default: User's $HOME directory
.PARAMETER WhatIf
    Run without deleting any files, just show what would be deleted.
.EXAMPLE
    .\cleanup.ps1 -filePath E:\ -limit 40 -days 365 -logFile cleanup.log
    All options are specified by name for maximum verbosity of the command.
.EXAMPLE
    .\cleanup.ps1 E:\ 40 365
    Only the required parameters can be passed to keep the command short.
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1)]
        [string]$filePath,
    [Parameter(Mandatory=$True,Position=2)]
        [int]$limit,
    [Parameter(Mandatory=$True,Position=3)]
        [int]$days,
    [Parameter(Mandatory=$False)]
        [string]$logFile = "$HOME\cleanup.log",
    [Parameter(Mandatory=$False)]
        [switch]$WhatIf
)

# log with a timestamp
function Log-Message {
    Param ([string]$longtext)
    Add-Content $logFile -value "$(Get-Date): $longtext"
}

# Calculate the size in human readable format
function Human-ReadableSize {
    Param ([double]$bytes)
    $inEnglish = 0
    switch($bytes) {
        {$_ -gt 1GB} {
            $inEnglish = '{0:0.0} GiB' -f ($_/1GB)
            break
        }
        {$_ -gt 1MB} {
            $inEnglish = '{0:0.0} MiB' -f ($_/1MB)
            break
        }
        {$_ -gt 1KB} {
            $inEnglish = '{0:0.0} KiB' -f ($_/1KB)
            break
        }
        default { 
            $inEnglish = "$_ bytes"
        }
    }
    return $inEnglish
}

% { (Log-Message "------------------------------------") }
% { (Log-Message "Starting Cleanup") }
% { (Log-Message " ") }

Write-Host "Calculating size of: $filePath"
% { (Log-Message "Calculating size of: $filePath") }

Write-Host "Maximum Size: $limit GB"
% { (Log-Message "Maximum Size: $limit GB") }

$pathSizeInBytes = (ls -r $filePath | measure -s Length).Sum
$currentSizeStr = Human-ReadableSize ($pathSizeInBytes)

Write-Host "Current Size: $currentSizeStr"
% { (Log-Message "Current Size: $currentSizeStr") }

if (($pathSizeInBytes/1GB) -lt $limit) {
    Write-Host "No cleanup needed"
    % { (Log-Message "No cleanup needed") }
} else {
    Write-Host "Cleaning..."
    % { (Log-Message "Cleaning...") }

    $calcLimit = (Get-Date).AddDays(-$days)
    Write-Host "Removing files older than: $calcLimit"
    Write-Host "Info about removed files can be found in $logFile"
    % { (Log-Message "Removing files older than: $calcLimit") }
    $dirs = Get-ChildItem -Path $filePath -Recurse -ErrorAction SilentlyContinue | Where-Object {$_.PSIsContainer}
    foreach ($dir in $dirs) {
        # Check to see if the path contains a directory
        if($dir) {
            $files = Get-ChildItem -Path $dir.FullName -Force -ErrorAction SilentlyContinue | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $calcLimit }
        } else {
            $files = Get-ChildItem -Path $filePath -Force -ErrorAction SilentlyContinue | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $calcLimit }
        }

        foreach ($file in $files) {
            # PS will run this block even if there is nothing in $files
            # so we have to check that there is something to work with.
            if($file) {
                $fullPath = "$($dir.FullName)\$file"
                % { (Log-Message "Removing: $fullPath") }
                Try { 
                    if($WhatIf) { Write-Host "Remove-Item $fullPath -Force -WhatIf" }
                    else { Write-Host "Remove-Item $fullPath -Force" }
                    
                }
                    Catch { % { (Log-Message "Can't Remove: $fullPath") } }
            }
        }
    }

}
% { (Log-Message "End of line.") }