# MGC CLI Install/Upgrade Scripts

> [!WARNING]
> This is an **unofficial** repository of Magalu Cloud CLI install scripts

These scripts will automate the process of checking the [official MGC CLI repository](https://github.com/MagaluCloud/mgccli/releases) for new packages, download and install them in your local machine.

## Usage

To install or upgrade the MGC CLI in your local machine, open a terminal and execute the commands below.


### Windows 

1. Run this command in a **Powershell** terminal:
   
   ```
   Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/rafaelvsouza/mgccli_installscripts/main/mgc_cli_install.ps1"))
   ```

2. Run this command if you want to add CLI installation folder to PATH variable (recommended):
   
   ```
   $env:Path += ";C:\Users\your-user\mgc-cli"
   ```

3. Restart the terminal

### Linux

1. Execute the following command in a terminal:
   
   ```
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/rafaelvsouza/mgccli_installscripts/main/mgc_cli_install.sh)"
   ```

### MacOS

Check the [official MGC CLI repository](https://github.com/MagaluCloud/mgccli?tab=readme-ov-file#macos) for instruction on how to install on a Mac using Homebrew.

