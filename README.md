# MGC CLI Install Scripts

> [!NOTE]
> This is an unofficial repository of Magalu Cloud CLI install scripts

These scripts will automate the process of checking the [official MGC CLI repository](https://github.com/MagaluCloud/mgccli/releases) for new packages, download and install them in your local machine.

- [Windows (powershell)](https://github.com/rafaelvsouza/mgccli_installscripts/blob/main/mgc_cli_install.ps1)
- [Linux or MacOS](https://github.com/rafaelvsouza/mgccli_installscripts/blob/main/mgc_cli_install.sh)

## Usage

Download the script to any folder and execute. :)

### Windows

**In a Powershell terminal:**

1. Run the installation script:

```
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/rafaelvsouza/mgccli_installscripts/main/mgc_cli_install.ps1"))
```

2. Update PATH variable with your installation folder:

```
$env:Path += ";C:\Users\your-user\mgc-cli"
```

3. Restart the terminal

### Linux

**In a terminal:**

1. Execute the following command
   
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/rafaelvsouza/mgccli_installscripts/main/mgc_cli_install.sh)"
```

