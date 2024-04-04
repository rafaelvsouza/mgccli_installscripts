<#
.SYNOPSIS
    Script to download and install the latest version of Magalu Cloud CLI for Windows.
.DESCRIPTION
    This script downloads the latest release of Magalu Cloud CLI for Windows AMD64 from a GitHub repository,
    unzips the downloaded package, moves the mgc.exe binary to a destination folder, updates the user PATH
    environment variable to include the destination folder, and cleans up temporary files.
.AUTHOR
    MGC CLI Squad
.DATE
    2024-04-02
.VERSION
    1.0
#>

# Function to make an API request
function Invoke-GitHubApiRequest {
    param(
        [string]$Url
    )

    try {
        $response = Invoke-RestMethod -Uri $Url -Method Get
        return $response
    } catch {
        Write-Error "Failed to retrieve data from GitHub API. Error: $_"
        return $false
    }
}

# Function to download a file
function Invoke-DownloadFile {
    param(
        [string]$Url,
        [string]$OutputFile
    )

    try {
        Invoke-WebRequest -Uri $Url -OutFile $OutputFile -ErrorAction Stop        
        return $true
    } catch {
        Write-Error "Failed to download file from $Url. Error: $_"
        return $false
    }
}

# Function to prompt for confirmation
function Confirm-Download {
    param (
        [string]$LatestFileName
    )
    
    $confirmation = Read-Host "Would you like to download '$LatestFileName'? (Y/N)"
    if ($confirmation -eq "Y" -or $confirmation -eq "y") {
        return $true
    } else {
        return $false
    }
}

# Function to prompt for confirmation before unzipping
function Confirm-Unzip {
    param (
        [string]$ZipFileName
    )
    
    $confirmation = Read-Host "Would you like to install the CLI from '$ZipFileName'? (Y/N)"
    if ($confirmation -eq "Y" -or $confirmation -eq "y") {
        return $true
    } else {
        return $false
    }
}
function Update-Path {
    param (
        [string]$addToPath
    )
    # Get the current PATH variable value
    $currentPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
    
    # Check if the directory is already in the PATH
    if (! $currentPath -like "*$addToPath*") {
        # Append the directory to the PATH
        $newPath = $addToPath + ";" + $currentPath

        # Set the updated PATH variable
        [System.Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        Write-Host -ForegroundColor Yellow "PATH environment variable updated to include $destinationFolder"
    }
    else {
        Write-Host -ForegroundColor Green "PATH environment variable already contains $destinationFolder"
    }
}

function Install-MGC {
    param (
        [string]$latestFileName
    )
    if (Confirm-Unzip -ZipFileName $latestFileName) {
        Write-Output ""
        Write-Host -ForegroundColor Yellow "Unzipping..."

        # Unzip the downloaded package to a temporary folder
        $tempFolder = New-Item -ItemType Directory -Path "mgc_temp" -Force
        Expand-Archive -Path $latestFileName -DestinationPath $tempFolder.FullName -Force
        
        $mgcBinary = Get-ChildItem -Path $tempFolder.FullName -Filter "mgc.exe" -Recurse | Select-Object -First 1
        if ($mgcBinary) {
            # Define the destination folder path inside user's home directory
            $destinationFolder = Join-Path -Path $env:USERPROFILE -ChildPath "mgc-cli"            
            # Check if the folder exists and create it if it doesn't
            if (-not (Test-Path -Path $destinationFolder -PathType Container)) {
                New-Item -Path $destinationFolder -ItemType Directory -Force
            }

            Move-Item -Path $mgcBinary.FullName -Destination $destinationFolder -Force 
            Write-Host -ForegroundColor Yellow "MGC CLI binary (mgc.exe) copied to $destinationFolder"
            
            # Update PATH environment variable
            Update-Path -addToPath $destinationFolder            
        } else {
            Write-Error "Failed to find mgc.exe in the downloaded package."
            exit 1
        }
        
        #Delete temporary folder
        Remove-Item -Path $tempFolder.FullName -Recurse -Force

        Write-Output ""
        Write-Output "Installation finished."
        Write-Output ""
        Write-Output "Next steps:"
        Write-Output "1. Run 'mgc --version' to verify CLI installation"
        Write-Output "2. Run 'mgc --help' to see available commands"
        Write-Output "3. Run 'mgc auth login' to authenticate the CLI"
        Write-Output "4. Read the CLI documentation in Magalu Cloud website"
        Write-Output ""
    } else {
        Write-Output "Installation cancelled by the user."
    }
}

# GitHub repository information
$owner = "MagaluCloud"
$repo = "mgccli"

Write-Output ""
Write-Output "Magalu Cloud CLI - Windows installation script"
Write-Output "=============================================="
Write-Output ""

# Get the latest release information
$latestReleaseUrl = "https://api.github.com/repos/$owner/$repo/releases"
$latestReleaseInfo = Invoke-GitHubApiRequest -Url $latestReleaseUrl
if ($latestReleaseInfo -eq $false) {
    Write-Error "Failed to retrieve latest release information."
    exit 1
}

# Extract the browser_download_url and name of the latest zip file with "windows_amd64" in its name
$latestFile = $latestReleaseInfo.assets | Where-Object { $_.name -like "mgc*windows_amd64.zip" } | Select-Object -First 1
$zipUrl = $latestFile.browser_download_url
$latestFileName = $latestFile.name
if (-not $zipUrl) {
    Write-Error "Failed to find the download URL for Windows AMD64 zip file."
    exit 1
}
Write-Output "Latest ZIP for Windows AMD64 is at: $zipUrl"
Write-Output ""

# Ask for confirmation before downloading
if (Confirm-Download -LatestFileName $latestFileName) {
    Write-Output ""
    # Download the zip file   
    Write-Host -ForegroundColor Yellow "Downloading file..."
    $downloaded = Invoke-DownloadFile -Url $zipUrl -OutputFile $latestFileName
    if ($downloaded) {
        Write-Output "Download successful."
        Write-Output "File saved as: $(Get-Location)\$latestFileName"
        Write-Output ""
        Install-MGC -latestFileName $latestFileName         
    } else {
        Write-Error "Failed to download file."
        exit 1
    }
} else {
    Write-Output "Download cancelled by the user."
    exit 0
}

Write-Output ""