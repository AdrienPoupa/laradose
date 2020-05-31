#!/bin/bash

DOWNLOADER=
GITHUB_URL=https://github.com/AdrienPoupa/laradose
VERSION=1.0.0

pause() {
  read -p "Press [Enter] key to continue..." fackEnterKey
}

install() {
  if [ -d ./docker ]; then
    fatal "Laradose is already installed"
  fi

	echo "Installing Laradose to the current directory..."

  copy_files

  configure

	echo "Laradose was installed successfully!"

	exit 0
}

copy_files() {
  verify_download curl || verify_download wget || fatal 'curl or wget are required for downloading files'
  verify_command unzip || fatal 'unzip is required for the installation script'

  echo "Downloading..."
	download laradose.zip ${GITHUB_URL}/archive/master.zip

  echo "Unzipping..."
	unzip -q laradose.zip -d laradose

  echo "Copying files..."
	cp -r ./laradose/laradose-master/docker ./docker
	cp ./laradose/laradose-master/docker-compose.yml ./
	cp ./laradose/laradose-master/.env.laradose ./
	cp ./laradose/laradose-master/laradose.sh ./laradose.sh

	rm -rf ./laradose
	rm ./laradose.zip
}

update() {
	echo "Be aware that this command will overwrite any modifications you made to Laradose configuration or Docker images."
	echo "Please make sure that your folder is versioned so you can revert to the previous state if needed."
	pause
	echo "Updating Laradose..."
	copy_files
	exit 0
}

configure() {
	echo "Laradose configuration"
	# TODO
	pause
}

uninstall() {
	echo "Uninstalling Laradose..."

	rm -rf ./docker
	rm ./docker-compose.yml
	rm ./.env.laradose

	echo "Laradose was uninstalled successfully!"

	exit 0
}

show_menus() {
	clear
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo "             L A R A D O S E"
	echo
	echo "Author: Adrien Poupa"
	echo "Version: "${VERSION}
	echo "URL: "${GITHUB_URL}
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo "1. Install"
	echo "2. Update"
	echo "3. Configure"
	echo "4. Uninstall"
	echo "0. Exit"
}

read_options() {
	local choice
	read -p "Enter choice [1 - 4] " choice
	case $choice in
		1) install ;;
		2) update ;;
		3) configure ;;
		4) uninstall ;;
		*) exit 0;;
	esac
}

# Credits https://raw.githubusercontent.com/rancher/k3s/master/install.sh
# --- verify existence of a command executable ---
verify_download() {
    verify_command

    # Set verified executable as our downloader program and return success
    DOWNLOADER=$1
    return 0
}

verify_command() {
    # Return failure if it doesn't exist or is no executable
    [ -x "$(which $1)" ] || return 1

    return 0
}

download() {
    [ $# -eq 2 ] || fatal 'download needs exactly 2 arguments'

    case $DOWNLOADER in
        curl)
            curl -o $1 -sfL $2
            ;;
        wget)
            wget -qO $1 $2
            ;;
        *)
            fatal "Incorrect executable '$DOWNLOADER'"
            ;;
    esac

    # Abort if download command failed
    [ $? -eq 0 ] || fatal 'Download failed'
}

fatal() {
    echo '[ERROR]' "$@" >&2
    exit 1
}

while true
do
  verify_command docker || fatal 'Docker is required for Laradose'
  verify_command docker-compose || fatal 'docker-compose is required for Laradose'
	show_menus
	read_options
done
