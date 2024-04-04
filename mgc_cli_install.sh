#!/bin/bash

################################################################################
# Script Name: mgc_cli_install.sh
# Description: This script checks for the latest version of MGC CLI on GitHub,
#              downloads the appropriate package based on the Linux distribution
#              and installs it.
# Author:      MGC CLI Squad
# Version:     1.0
# Date:        2024-04-02
# Usage:       ./mgc_cli_install.sh
################################################################################


# Detect operating system
os=$(uname)
architecture=$(uname -m)

if [[ "$os" != "Linux" ]]; then
    echo "This installation script is for Linux only."
    exit 1
else
    # Check if the architecture is ARM
    if [[ $architecture == "arm"* ]]; then
        arch="arm64"
    elif [[ $architecture == "x86_64" ]]; then
        arch="amd64"
    else
        echo "Unknown architecture: $architecture"
        exit 1
    fi
fi 

# Detect Linux distribution
distro=$(lsb_release -si)

# Extract the URL of the appropriate package based on the Linux distribution
if [[ "$distro" == "Ubuntu" || "$distro" == "Debian" || "$distro" == "Mint" || "$distro" == "MX" ]]; then    
    package_type="deb"
elif [[ "$distro" == "Fedora" || "$distro" == "CentOS" || "$distro" == "Red Hat" ]]; then    
    package_type="rpm"
else    
    package_type="tar.gz"
fi

# Define the owner and repository on GitHub
owner="MagaluCloud"
repo="mgccli"
filter_regex="browser_download_url.*(/mgccli_|/mgc_).*linux_$arch"

# Welcome message
echo ""
echo "Magalu Cloud CLI - Linux installation script"
echo "============================================"
echo "" 

# Ask for confirmation about the release type
#read -p "What is the release tag? [enter=latest]: " tagInput
#echo ""
#if [[ ! -z "$tagInput" ]]; then        
#    echo "Fetching a specific tag..."
#    repo_url="https://api.github.com/repos/$owner/$repo/releases/tags/$tagInput"    
#else
#    echo "Fetching only the latest release..."
#    repo_url="https://api.github.com/repos/$owner/$repo/releases/latest"
#fi

repo_url="https://api.github.com/repos/$owner/$repo/releases"

# Fetch the latest release URL from GitHub API
response=$(curl -s $repo_url)

url_line=$(echo "$response" | grep -E -m 1 "$filter_regex.$package_type")

# Extract the URL portion from the line
url=$(echo "$url_line" | cut -d : -f 2,3 | tr -d \")

# Print the URL of the latest release
echo "Latest $package_type package URL: $url"
echo "" 

# Extract the filename from the URL
filename=$(basename $url)

# Ask for confirmation before downloading the file
read -p "Do you want to download $filename? [Y/n]: " choice
if [[ ! $choice =~ ^[Yy]$ ]]; then
    echo "Download cencelled by the user."
    exit 0
fi

echo "Downloading file..."
# Download the latest release
if wget -q --content-disposition $url; then
    echo "Download successful. File saved as: $PWD/$filename"
else
    echo "Download failed."
    exit 1
fi
echo "" 

# Ask for confirmation before installing 
read -p "Do you want to install $filename? [Y/n]: " choice
if [[ $choice =~ ^[Yy]$ ]]; then
    # Install the package based on Linux distribution
    if [[ "$package_type" == "deb" ]]; then
        # Install the .deb file
        sudo dpkg -i $filename
    elif [[ "$package_type" == "rpm" ]]; then
        # Install the .rpm file
        sudo rpm -i $filename
    else
        # Extract the .tar.gz file and copy it to /usr/bin
        tar -xzf $filename -C ~/mgc_temp
        sudo cp -f ~/mgc_temp/mgc /usr/bin
        rm -rf ~/mgc_temp
        echo "MGC CLI binary copied to /usr/bin"
        echo ""
    fi
    echo "Installation finished."
    echo ""
    echo "Next steps:"
    echo "1. Run 'mgc --version' to verify CLI installation"
    echo "2. Run 'mgc --help' to see available commands"
    echo "3. Run 'mgc auth login' to authenticate the CLI"
    echo "4. Read the CLI documentation in Magalu Cloud website"
    echo ""
else
    echo "Installation aborted by the user."
fi
