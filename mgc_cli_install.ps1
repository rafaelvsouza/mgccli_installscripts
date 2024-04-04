<#
.SYNOPSIS
    Script to download and install the latest version of Magalu Cloud CLI for Windows.
.DESCRIPTION
    This script downloads the latest release of Magalu Cloud CLI for Windows AMD64 from a GitHub repository,
    unzips the downloaded package, moves the mgc.exe binary to a destination folder, updates the user PATH
    environment variable to include the destination folder, and cleans up temporary files.
.AUTHOR
    Rafael S
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
# SIG # Begin signature block
# MIIbnQYJKoZIhvcNAQcCoIIbjjCCG4oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU1cbC+BUWP2ilIpdIFARcTWN8
# NWKgghYTMIIDBjCCAe6gAwIBAgIQc2SHYVoad7BPRiGJZ585KjANBgkqhkiG9w0B
# AQsFADAbMRkwFwYDVQQDDBBBVEEgQXV0aGVudGljb2RlMB4XDTI0MDQwNDIxMTI0
# NFoXDTI1MDQwNDIxMzI0NFowGzEZMBcGA1UEAwwQQVRBIEF1dGhlbnRpY29kZTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAL5uffF5AR9WQtrUSTQcCyPz
# cKyGR0nZjDVKG3AUqgiNj4Zr1VbRAbqY/Oj3MRNCZexGlenb0lMa7U1ZEHLFwr+m
# e+z5tbzGJr9csRFXnYzsYBpFiaRruwefed3xtF4H2cxDY0XqI7aFDlNXi2zsU8vb
# +PxPyTDvNFOt6dWZA2N+O0p1ZBoC6G8g+xz20TFAVrl8vIRmhZ/11R2ADNbwzHBT
# JhO1JWQ2NLJYqvH/6i7pBB93paO7OwiheXPC76ogwUEe/R+4g5MYDfXvRYirqFhj
# fRqf9pY/G2FZinroecSiUUIIR2v5N6OWvSzRo1w3NR3QvNLPxM0ifMSlwmuiRqkC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBSDVVpd2VMMDx4rEezwNRPJmd116jANBgkqhkiG9w0BAQsFAAOCAQEA
# IOMn74q+aa0WM9aWkxy43xU20Yk685Vk7thv1ldZ66lWiNoq+M14FxzZmh/NXxK1
# ZXZw25IXVsiKc0yv75zAeQMsS9ZL622IzJtF1FdUxdzE8BbaPQAxgIeL+WvSTdV8
# s6CMcbVFLa9zRfyATIomldo/HtP4XPXD+xLm2cqSwQ7RS9h9pKz3d5FZjt7WdM5F
# OHKk3y0CVCtB5ovnhDVi+NdA5MStoc+queOhWo1kKrAG/dj6iu9iYHj5Fv5n+QPD
# KzBHOx6Tv/nfUzfXDYfVYopK4MV/ZGRj7P2FID9jVnheQpZFz8cMUAUojn39Szhx
# iBOJo0eSAEQr+5ttmTBZMTCCBY0wggR1oAMCAQICEA6bGI750C3n79tQ4ghAGFow
# DQYJKoZIhvcNAQEMBQAwZTELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0
# IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNl
# cnQgQXNzdXJlZCBJRCBSb290IENBMB4XDTIyMDgwMTAwMDAwMFoXDTMxMTEwOTIz
# NTk1OVowYjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcG
# A1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3Rl
# ZCBSb290IEc0MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAv+aQc2je
# u+RdSjwwIjBpM+zCpyUuySE98orYWcLhKac9WKt2ms2uexuEDcQwH/MbpDgW61bG
# l20dq7J58soR0uRf1gU8Ug9SH8aeFaV+vp+pVxZZVXKvaJNwwrK6dZlqczKU0RBE
# EC7fgvMHhOZ0O21x4i0MG+4g1ckgHWMpLc7sXk7Ik/ghYZs06wXGXuxbGrzryc/N
# rDRAX7F6Zu53yEioZldXn1RYjgwrt0+nMNlW7sp7XeOtyU9e5TXnMcvak17cjo+A
# 2raRmECQecN4x7axxLVqGDgDEI3Y1DekLgV9iPWCPhCRcKtVgkEy19sEcypukQF8
# IUzUvK4bA3VdeGbZOjFEmjNAvwjXWkmkwuapoGfdpCe8oU85tRFYF/ckXEaPZPfB
# aYh2mHY9WV1CdoeJl2l6SPDgohIbZpp0yt5LHucOY67m1O+SkjqePdwA5EUlibaa
# RBkrfsCUtNJhbesz2cXfSwQAzH0clcOP9yGyshG3u3/y1YxwLEFgqrFjGESVGnZi
# fvaAsPvoZKYz0YkH4b235kOkGLimdwHhD5QMIR2yVCkliWzlDlJRR3S+Jqy2QXXe
# eqxfjT/JvNNBERJb5RBQ6zHFynIWIgnffEx1P2PsIV/EIFFrb7GrhotPwtZFX50g
# /KEexcCPorF+CiaZ9eRpL5gdLfXZqbId5RsCAwEAAaOCATowggE2MA8GA1UdEwEB
# /wQFMAMBAf8wHQYDVR0OBBYEFOzX44LScV1kTN8uZz/nupiuHA9PMB8GA1UdIwQY
# MBaAFEXroq/0ksuCMS1Ri6enIZ3zbcgPMA4GA1UdDwEB/wQEAwIBhjB5BggrBgEF
# BQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBD
# BggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0
# QXNzdXJlZElEUm9vdENBLmNydDBFBgNVHR8EPjA8MDqgOKA2hjRodHRwOi8vY3Js
# My5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMBEGA1Ud
# IAQKMAgwBgYEVR0gADANBgkqhkiG9w0BAQwFAAOCAQEAcKC/Q1xV5zhfoKN0Gz22
# Ftf3v1cHvZqsoYcs7IVeqRq7IviHGmlUIu2kiHdtvRoU9BNKei8ttzjv9P+Aufih
# 9/Jy3iS8UgPITtAq3votVs/59PesMHqai7Je1M/RQ0SbQyHrlnKhSLSZy51PpwYD
# E3cnRNTnf+hZqPC/Lwum6fI0POz3A8eHqNJMQBk1RmppVLC4oVaO7KTVPeix3P0c
# 2PR3WlxUjG/voVA9/HYJaISfb8rbII01YBwCA8sgsKxYoA5AY8WYIsGyWfVVa88n
# q2x2zm8jLfR+cWojayL/ErhULSd+2DrZ8LaHlv1b0VysGMNNn3O3AamfV6peKOK5
# lDCCBq4wggSWoAMCAQICEAc2N7ckVHzYR6z9KGYqXlswDQYJKoZIhvcNAQELBQAw
# YjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQ
# d3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290
# IEc0MB4XDTIyMDMyMzAwMDAwMFoXDTM3MDMyMjIzNTk1OVowYzELMAkGA1UEBhMC
# VVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2VydCBU
# cnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTCCAiIwDQYJ
# KoZIhvcNAQEBBQADggIPADCCAgoCggIBAMaGNQZJs8E9cklRVcclA8TykTepl1Gh
# 1tKD0Z5Mom2gsMyD+Vr2EaFEFUJfpIjzaPp985yJC3+dH54PMx9QEwsmc5Zt+Feo
# An39Q7SE2hHxc7Gz7iuAhIoiGN/r2j3EF3+rGSs+QtxnjupRPfDWVtTnKC3r07G1
# decfBmWNlCnT2exp39mQh0YAe9tEQYncfGpXevA3eZ9drMvohGS0UvJ2R/dhgxnd
# X7RUCyFobjchu0CsX7LeSn3O9TkSZ+8OpWNs5KbFHc02DVzV5huowWR0QKfAcsW6
# Th+xtVhNef7Xj3OTrCw54qVI1vCwMROpVymWJy71h6aPTnYVVSZwmCZ/oBpHIEPj
# Q2OAe3VuJyWQmDo4EbP29p7mO1vsgd4iFNmCKseSv6De4z6ic/rnH1pslPJSlREr
# WHRAKKtzQ87fSqEcazjFKfPKqpZzQmiftkaznTqj1QPgv/CiPMpC3BhIfxQ0z9JM
# q++bPf4OuGQq+nUoJEHtQr8FnGZJUlD0UfM2SU2LINIsVzV5K6jzRWC8I41Y99xh
# 3pP+OcD5sjClTNfpmEpYPtMDiP6zj9NeS3YSUZPJjAw7W4oiqMEmCPkUEBIDfV8j
# u2TjY+Cm4T72wnSyPx4JduyrXUZ14mCjWAkBKAAOhFTuzuldyF4wEr1GnrXTdrnS
# DmuZDNIztM2xAgMBAAGjggFdMIIBWTASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1Ud
# DgQWBBS6FtltTYUvcyl2mi91jGogj57IbzAfBgNVHSMEGDAWgBTs1+OC0nFdZEzf
# Lmc/57qYrhwPTzAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUHAwgw
# dwYIKwYBBQUHAQEEazBpMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2Vy
# dC5jb20wQQYIKwYBBQUHMAKGNWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9E
# aWdpQ2VydFRydXN0ZWRSb290RzQuY3J0MEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6
# Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290RzQuY3JsMCAG
# A1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATANBgkqhkiG9w0BAQsFAAOC
# AgEAfVmOwJO2b5ipRCIBfmbW2CFC4bAYLhBNE88wU86/GPvHUF3iSyn7cIoNqilp
# /GnBzx0H6T5gyNgL5Vxb122H+oQgJTQxZ822EpZvxFBMYh0MCIKoFr2pVs8Vc40B
# IiXOlWk/R3f7cnQU1/+rT4osequFzUNf7WC2qk+RZp4snuCKrOX9jLxkJodskr2d
# fNBwCnzvqLx1T7pa96kQsl3p/yhUifDVinF2ZdrM8HKjI/rAJ4JErpknG6skHibB
# t94q6/aesXmZgaNWhqsKRcnfxI2g55j7+6adcq/Ex8HBanHZxhOACcS2n82HhyS7
# T6NJuXdmkfFynOlLAlKnN36TU6w7HQhJD5TNOXrd/yVjmScsPT9rp/Fmw0HNT7ZA
# myEhQNC3EyTN3B14OuSereU0cZLXJmvkOHOrpgFPvT87eK1MrfvElXvtCl8zOYdB
# eHo46Zzh3SP9HSjTx/no8Zhf+yvYfvJGnXUsHicsJttvFXseGYs2uJPU5vIXmVnK
# cPA3v5gA3yAWTyf7YGcWoWa63VXAOimGsJigK+2VQbc61RWYMbRiCQ8KvYHZE/6/
# pNHzV9m8BPqC3jLfBInwAM1dwvnQI38AC+R2AibZ8GV2QqYphwlHK+Z/GqSFD/yY
# lvZVVCsfgPrA8g4r5db7qS9EFUrnEw4d2zc4GqEr9u3WfPwwggbCMIIEqqADAgEC
# AhAFRK/zlJ0IOaa/2z9f5WEWMA0GCSqGSIb3DQEBCwUAMGMxCzAJBgNVBAYTAlVT
# MRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1
# c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0EwHhcNMjMwNzE0
# MDAwMDAwWhcNMzQxMDEzMjM1OTU5WjBIMQswCQYDVQQGEwJVUzEXMBUGA1UEChMO
# RGlnaUNlcnQsIEluYy4xIDAeBgNVBAMTF0RpZ2lDZXJ0IFRpbWVzdGFtcCAyMDIz
# MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAo1NFhx2DjlusPlSzI+DP
# n9fl0uddoQ4J3C9Io5d6OyqcZ9xiFVjBqZMRp82qsmrdECmKHmJjadNYnDVxvzqX
# 65RQjxwg6seaOy+WZuNp52n+W8PWKyAcwZeUtKVQgfLPywemMGjKg0La/H8JJJSk
# ghraarrYO8pd3hkYhftF6g1hbJ3+cV7EBpo88MUueQ8bZlLjyNY+X9pD04T10Mf2
# SC1eRXWWdf7dEKEbg8G45lKVtUfXeCk5a+B4WZfjRCtK1ZXO7wgX6oJkTf8j48qG
# 7rSkIWRw69XloNpjsy7pBe6q9iT1HbybHLK3X9/w7nZ9MZllR1WdSiQvrCuXvp/k
# /XtzPjLuUjT71Lvr1KAsNJvj3m5kGQc3AZEPHLVRzapMZoOIaGK7vEEbeBlt5NkP
# 4FhB+9ixLOFRr7StFQYU6mIIE9NpHnxkTZ0P387RXoyqq1AVybPKvNfEO2hEo6U7
# Qv1zfe7dCv95NBB+plwKWEwAPoVpdceDZNZ1zY8SdlalJPrXxGshuugfNJgvOupr
# AbD3+yqG7HtSOKmYCaFxsmxxrz64b5bV4RAT/mFHCoz+8LbH1cfebCTwv0KCyqBx
# PZySkwS0aXAnDU+3tTbRyV8IpHCj7ArxES5k4MsiK8rxKBMhSVF+BmbTO77665E4
# 2FEHypS34lCh8zrTioPLQHsCAwEAAaOCAYswggGHMA4GA1UdDwEB/wQEAwIHgDAM
# BgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMCAGA1UdIAQZMBcw
# CAYGZ4EMAQQCMAsGCWCGSAGG/WwHATAfBgNVHSMEGDAWgBS6FtltTYUvcyl2mi91
# jGogj57IbzAdBgNVHQ4EFgQUpbbvE+fvzdBkodVWqWUxo97V40kwWgYDVR0fBFMw
# UTBPoE2gS4ZJaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3Rl
# ZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFtcGluZ0NBLmNybDCBkAYIKwYBBQUHAQEE
# gYMwgYAwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBYBggr
# BgEFBQcwAoZMaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1
# c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFtcGluZ0NBLmNydDANBgkqhkiG9w0B
# AQsFAAOCAgEAgRrW3qCptZgXvHCNT4o8aJzYJf/LLOTN6l0ikuyMIgKpuM+AqNnn
# 48XtJoKKcS8Y3U623mzX4WCcK+3tPUiOuGu6fF29wmE3aEl3o+uQqhLXJ4Xzjh6S
# 2sJAOJ9dyKAuJXglnSoFeoQpmLZXeY/bJlYrsPOnvTcM2Jh2T1a5UsK2nTipgedt
# QVyMadG5K8TGe8+c+njikxp2oml101DkRBK+IA2eqUTQ+OVJdwhaIcW0z5iVGlS6
# ubzBaRm6zxbygzc0brBBJt3eWpdPM43UjXd9dUWhpVgmagNF3tlQtVCMr1a9TMXh
# RsUo063nQwBw3syYnhmJA+rUkTfvTVLzyWAhxFZH7doRS4wyw4jmWOK22z75X7BC
# 1o/jF5HRqsBV44a/rCcsQdCaM0qoNtS5cpZ+l3k4SF/Kwtw9Mt911jZnWon49qfH
# 5U81PAC9vpwqbHkB3NpE5jreODsHXjlY9HxzMVWggBHLFAx+rrz+pOt5Zapo1iLK
# O+uagjVXKBbLafIymrLS2Dq4sUaGa7oX/cR3bBVsrquvczroSUa31X/MtjjA2Owc
# 9bahuEMs305MfR5ocMB3CtQC4Fxguyj/OOVSWtasFyIjTvTs0xf7UGv/B3cfcZdE
# Qcm4RtNsMnxYL2dHZeUbc7aZ+WssBkbvQR7w8F/g29mtkIBEr4AQQYoxggT0MIIE
# 8AIBATAvMBsxGTAXBgNVBAMMEEFUQSBBdXRoZW50aWNvZGUCEHNkh2FaGnewT0Yh
# iWefOSowCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJ
# KoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQB
# gjcCARUwIwYJKoZIhvcNAQkEMRYEFNPFK97S2oCrUvhT8k+cwcuNVaOrMA0GCSqG
# SIb3DQEBAQUABIIBAGCCthReAiUhw29lDqUv44eofbPtJq8nsIQtkc9qnYVqBhud
# t2GnLVmwg0q29JTdZAXKt+YHoJkFHBaRmgD+ON5RmEgG60l/hVk6yMA0kDXNYCrb
# eouXtlif51xPQQ4oMIKCmMNOx1iPDn5TwaJFLSTb6Tcw8VoGim+dsxTYDbpYclgC
# F/6G9GELNUkM+0Xzu0VsSX6/AfCha3E/V4ubFHYaRWvzBPy4/slTH4Udhb6cdZby
# CE0rjmiBaNC3Kjs/5dLNluArwwPrOjjp6P5Ma+Dy04/tX+mDGkIpy52V+7w/bSt0
# SDT0uBw5jg348I0DYMIhQ2LQJUs+SPtGsPlZ+PGhggMgMIIDHAYJKoZIhvcNAQkG
# MYIDDTCCAwkCAQEwdzBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQs
# IEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEy
# NTYgVGltZVN0YW1waW5nIENBAhAFRK/zlJ0IOaa/2z9f5WEWMA0GCWCGSAFlAwQC
# AQUAoGkwGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcN
# MjQwNDA0MjEyOTI4WjAvBgkqhkiG9w0BCQQxIgQgMXaW0mRuT+mWQgowQ/SZqeVn
# 8aIJnGrcJkubNqT4820wDQYJKoZIhvcNAQEBBQAEggIAPt8tbQ30pFMp2xmsfXh0
# Fg4UyvaHRkYBSkLsR/EuMqslVCRFO6xLoB8iqPUq59U/bRD0kSnggvjA7YlWjv24
# PJ9pVX+5eSxSXcFcxeKu8vGpz7QGOdoxG36rMU4dfBPY2r3taeCw7+POb4J88U+3
# YWwnRDexVXNhz0qdAPC2X+RzFiTLFdCsq8xVRWs5sQswQ2o8A6o920WsE9ypPIgX
# qH9kyKTr5KtIT4ozWRDgWqCTSjcpcCc1uxqShkIKQHjlz0SkI95+Rnb3x6YIwKlj
# 7x+OFlI3Z2f26aFDibJXg/FzYV2rQcAoD2tf1PMsw5GK6elTUcPQRzTeiSDiq7Us
# 6xrzm1J5WmZczDwt7ypRPiYyS8KZxVwUvsMn5jBkgUYLKpE/FAFhs40LkCR4ZuHT
# TltFqpErGT6KcVnAVEI5IzoYW28oiG670c5w7vMbM52V/O4cbQ/60Aq/fsXLQt8f
# 9NKMYDbpo9xFcaLNhNZvYpw9O6taAla8VA2LpIBdvjHTtnOrjXYAcILdtkf3G9eG
# +Sa1YBxnn5RyQnD0QV3YApJJaocbQdyT1TaimRjPuAuxJ9IAN11Fcc9oIxkWGgXy
# rK72i3ni1ZnEhZlqq0t7sSUWEDsdMFOJshus6NE2vpn/Ekli2yzchv0Mk8OXgPZi
# HhdYH9sRb8y6wnKC2ueWoiQ=
# SIG # End signature block
