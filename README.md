# The Code Profiles | Multi-profile manager for VS Code.
Simple tool to create and manage multiple profiles of vs code with different settings, themes and extensions. Essential for any developer that uses multiple languages with different setup for each one.

## Installation

Simply run the installation script.

    sudo ./install.sh

Make sure the script is executable by running the following command before running the installation script.

    chmod +x install.sh
**Please note:** that the installation uses a pre-compiled binary included in the "binaries" folder,
However you can compile your own binary using the script included in the "scripts" folder. make sure to replace the included binary with your own in the "binaries" folder before running the installation script.


## Usage

Simply run the following command:

    codeprofiles [-p profile] [-s] [-h]
### Options:
`-s` | Run in silent mode. if a profile is specified using the `-p` option the script will run VS Code with the specified profile and exit silently without showing the full interface.

`-p [profile]` | Specify a profile to launch immediately as the script launches.

`-h` | Get instructions.