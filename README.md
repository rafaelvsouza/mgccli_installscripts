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

1. Run the script:
```
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression -Command "mgc_cli_install.ps1"
```
2. Update PATH variable:
```
$env:Path += ";C:\Users\your-user\mgc-cli"
```
3. Restart the terminal

### Linux or Mac

**In a terminal:**

1. Make it executable with the command:
```
chmod +x mgc_cli_install.sh
```
3. Run the script:
```
./mgc_cli_install.sh
``` 
