#!/bin/bash

DOWNLOADER=
GITHUB_URL=https://github.com/AdrienPoupa/laradose
VERSION=1.0.0

install() {
  if [ -d ./docker ]; then
  fatal "Laradose is already installed"
  fi

  echo "Installing Laradose to the current directory..."

  copy_files

  generate_ssl_certificate

  post_install_commands

  configure
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
  cp ./laradose/laradose-master/laradose.sh ./laradose.sh

  cat ./laradose/laradose-master/.env.example >> ./.env.example
  cat ./laradose/laradose-master/.env.example >> ./.env

  cat ./laradose/laradose-master/webpack.mix.js >> ./webpack.mix.js

  rm -rf ./laradose
  rm ./laradose.zip
}

generate_ssl_certificate() {
  echo "Generating SSL certificate..."

  # Create private and public key
  openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout ./docker/nginx/keys/server.key -out ./docker/nginx/keys/server.crt -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=localhost" > /dev/null 2>&1

  # Create csr file
  openssl req -new -key ./docker/nginx/keys/server.key -out ./docker/nginx/keys/server.csr -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=localhost" > /dev/null 2>&1
}

update() {
  echo "Be aware that this command will overwrite any modifications you made to Laradose configuration or Docker images."
  echo "Please make sure that your folder is versioned so you can revert to the previous state if needed."
  read -r -p "Press any key to continue..."
  echo "Updating Laradose..."
  copy_files
  exit 0
}

# Menu inspired by https://serverfault.com/a/298312
additional_containers_menu() {
  echo "Select the additional containers you want to enable:"
  for i in "${!options[@]}"; do
    printf "%d. %s %s\n" $((i+1)) "${options[i]}" "${choices[i]:-}"
  done
  if [[ "$msg" ]]; then echo "$msg"; fi
}

configure() {
  echo "Laradose configuration"

  # Export the vars in .env into your shell:
  export $(grep -E -v '^#' .env | xargs)

  options=("Queue" "Redis" "Laravel Horizon" "phpMyAdmin" "MailHog")
  folders=("queue" "redis" "horizon" "phpmyadmin" "mailhog")

  # Fill already selected options
  for i in "${!folders[@]}"; do
    if [[ $COMPOSE_FILE == *${folders[i]}* ]]; then
      choices[i]=$'\u2713'
    fi
  done

  prompt="Type the container number (again to uncheck, ENTER when done): "
  while additional_containers_menu && read -rp "$prompt" num && [[ "$num" ]]; do
    [[ "$num" != *[![:digit:]]* ]] &&
    (( num > 0 && num <= ${#options[@]} )) ||
    { msg="Invalid option: $num"; continue; }
    ((num--)); msg="${options[num]} was ${choices[num]:+un}enabled"
    [[ "${choices[num]}" ]] && choices[num]="" || choices[num]=$'\u2713'
  done

  compose_file_input="docker-compose.yml:"
  for i in "${!options[@]}"; do
    [[ "${choices[i]}" ]] && compose_file_input=$compose_file_input"docker/${folders[i]}/docker-compose.override.yml":
  done

  # Remove last :
  compose_file_input=${compose_file_input%?}

  sed -i "s#COMPOSE_PROJECT_NAME=.*#COMPOSE_PROJECT_NAME=${APP_NAME}#" ./.env

  sed -i "s#DB_HOST=.*#DB_HOST=mysql#" ./.env

  sed -i "s#DB_PASSWORD=.*#DB_PASSWORD=${DB_USERNAME}#" ./.env

  sed -i "s#COMPOSE_FILE=.*#COMPOSE_FILE=${compose_file_input}#" ./.env

  env_input "NGINX_HTTPS_PORT" "Nginx HTTPS port"

  env_input "NGINX_HTTP_PORT" "Nginx HTTP port"

  env_input "DB_PORT" "MySQL port"

  env_input "WEBPACK_PORT" "Webpack Development Server port"

  if [[ $compose_file_input == *"redis"* ]]; then
    sed -i "s#REDIS_HOST=.*#REDIS_HOST=redis#" ./.env

    env_input "REDIS_PORT" "Redis port"
  fi

  if [[ $compose_file_input == *"phpmyadmin"* ]]; then
    env_input "PHPMYADMIN_PORT" "phpMyAdmin port"
  fi

  if [[ $compose_file_input == *"mailhog"* ]]; then
    sed -i "s#MAIL_HOST=.*#MAIL_HOST=mailhog#" ./.env

    sed -i "s#MAIL_MAILER=.*#MAIL_MAILER=smtp#" ./.env

    sed -i "s#MAIL_PORT=.*#MAIL_PORT=1025#" ./.env

    env_input "MAILHOG_PORT" "MailHog port"
  fi

  env_input "PHP_VERSION" "PHP Version (7.2, 7.3, 7.4)"

  env_input "PHP_SERVER_NAME" "PHP Server Name for xdebug"

  env_input "USER_ID" "Linux User ID for file permissions (current user: $(id -u))"

  env_input "GROUP_ID" "Linux Group ID for file permissions (current group: $(id -g))"

  env_input "MIX_MODE" "Mix mode can be one of: watch, hot, dev, prod"

  env_input "MIX_BROWSERSYNC" "Enable Browsersync (enabled or disabled)"

  if [[ $new_value == "enabled" || $new_value == "" && $MIX_BROWSERSYNC == "enabled" ]]; then
    env_input "MIX_BROWSERSYNC_PORT" "Browsersync port"

    env_input "MIX_BROWSERSYNC_ADMIN_PORT" "Browsersync admin port"
  fi

  echo "Configuration complete! Restart docker-compose to apply the changes."

  exit 0
}

env_input() {
  key=$1
  description=$2

  read -r -p "$description: [${!key}] " new_value

  if [ -n "$new_value" ]; then
    sed -i "s/${key}=.*/${key}=${new_value}/" ./.env
  fi
}

post_install_commands() {
  echo "Applying permissions..."
  chown -R "$(id -u)":"$(id -g)" .
  chmod -R 755 .

  chmod +x artisan

  # Add the https argument to the "hot" npm run option,
  # since the webpack option passed in webpack is apparently not enough
  sed -i "s/--disable-host-check/--disable-host-check --https/" package.json
}

uninstall() {
  echo "Uninstalling Laradose..."

  rm -rf ./docker
  rm ./docker-compose.yml

  echo "Laradose was uninstalled successfully!"
  echo "You can now remove additional entries from your .env and .env.example files"

  exit 0
}

show_menus() {
  clear
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  echo "       L A R A D O S E"
  echo
  echo "Author: Adrien Poupa"
  echo "Version: "${VERSION}
  echo "URL: "${GITHUB_URL}
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  echo "1. Configure"
  echo "2. Update"
  echo "3. Uninstall"
  echo "0. Exit"
}

read_options() {
  local choice
  read -r -p "Enter choice [1 - 3] " choice
  case $choice in
    1) configure ;;
    2) update ;;
    3) uninstall ;;
    *) exit 0;;
  esac
}

# Credits https://raw.githubusercontent.com/rancher/k3s/master/install.sh
verify_download() {
  verify_command

  # Set verified executable as our downloader program and return success
  DOWNLOADER=$1
  return 0
}

# --- verify existence of a command executable ---
verify_command() {
  # Return failure if it doesn't exist or is no executable
  [ -x "$(command -v "$1")" ] || return 1

  return 0
}

download() {
  [ $# -eq 2 ] || fatal 'download needs exactly 2 arguments'

  case $DOWNLOADER in
    curl)
      curl -o "$1" -sfL "$2"
      ;;
    wget)
      wget -qO "$1" "$2"
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

if [ "$1" == "--install" ]
then
  install
  exit 0
fi

while true
do
  verify_command docker || fatal 'Docker is required for Laradose'
  verify_command docker-compose || fatal 'docker-compose is required for Laradose'
  if ! [ -f ./.env ]; then
  fatal 'You must have a .env file'
  fi
  show_menus
  read_options
done
