# Laradose

Laradose aims to bring a light yet powerful and configurable Docker compose configuration to run a Laravel
application locally. Installation and configuration are made easy with the provided Bash script. 
Six containers are installed out of the box:

- PHP with configurable versions and xdebug support
- Nginx with HTTPS support
- MySQL with automatic database import
- Artisan to run Laravel Artisan commands
- Composer to install PHP packages
- NPM with Hot Module Reload and Browsersync support

Additional containers can be enabled:

- Queues: Laravel's default queue manager
- Redis: in-memory database to store cache
- Laravel Horizon: Redis-powered queue manager
- MailHog: local email server
- PHPMyAdmin: database management

1. [Requirements](#1-requirements)
2. [Installation Instructions](#2-installation-instructions)
   1. [Automated installation](#21-automated-installation)
   2. [Manual installation](#22-manual-installation)
3. [Usage](#3-usage)
   1. [Configuration](#31-configuration)
   2. [Commands](#32-commands)
4. [Container Specific Instructions](#4-container-specific-instructions)
   1. [PHP](#41-php)
      1. [Setup xdebug for PHPStorm](#411-setup-xdebug-for-phpstorm)
   2. [MySQL](#42-mysql)
      1. [Import a dump](#421-import-a-dump)
   3. [NPM](#43-npm)
      1. [Hot Module Reload](#431-hot-module-reload)
      2. [Browsersync](#432-browsersync)
5. [Available Parameters](#5-available-parameters)
6. [Q&A](#6-qa)

## 1. Requirements

- [Docker](https://docs.docker.com/engine/install//)
- [Docker Compose](https://docs.docker.com/compose/install/)

This was tested on Linux. It may or may not work on Windows or MacOS.

## 2. Installation Instructions

### 2.1 Automated installation

A Bash script is provided to install Laradose automatically. It will add the required files to your project's folder
and help you configure Laradose. This is the preferred method. Before running the script, it is recommended to commit
your project so you can revert to the previous state if needed. To use it, `cd` into your project's folder and run:

```
$ wget https://raw.githubusercontent.com/AdrienPoupa/laradose/master/laradose.sh && chmod +x laradose.sh
$ ./laradose.sh --install
```

The script will:

1. Download this repository's files
2. Copy them in your project's folder
3. Generate the SSL certificates needed for HTTPS
4. Modify the following files to adapt them to the local environment: `.env.`, `.env.example`, `package.json`, `webpack.mix.js`
5. Apply the correct permissions
6. Run the configuration tool to specify which containers should be enabled, on which ports, etc

It is recommended to commit your files before running the script,
so you can rollback the modifications it made if needed.

### 2.2 Manual installation

You can install Laradose manually if you do not wish to use the script.

1. Copy the following into your project folder:
- The `docker` folder
- The `docker-compose.yml` file
2. Append the content of `.env` to your `.env` file
3. Set `DB_HOST=mysql` and `REDIS_HOST=redis`
4. Generate the SSL certificates:
```
$ openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout ./docker/nginx/keys/server.key -out ./docker/nginx/keys/server.crt -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=localhost" > /dev/null 2>&1
$ openssl req -new -key ./docker/nginx/keys/server.key -out ./docker/nginx/keys/server.csr -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=localhost" > /dev/null 2>&1
```
5. Append the content of `webpack.mix.js` to your `webpack.mix.js` file
6. Add the `--https` argument to the `hot` section of your `package.json`
7. Set write permissions on the host: `$ chown -R $(id -u):$(id -g) . && chmod -R 755 .`
8. You can configure the environment variables manually as shown in [Available Parameters](#5-available-parameters).

## 3. Usage

If you need to import a database dump, place it in the `docker/mysql` folder. It will be imported automatically when
the MySQL container boots.

### 3.1 Configuration

Run the Laradose script:

```
$ ./laradose.sh
```

Use the `1. Configure` option of the Laradose script to configure your installation. You will be able to enable and
disable the additional containers and change the options shown in [Available Parameters](#5-available-parameters).
Be aware the script will update your `.env` file.

### 3.2 Commands

Run the project. It will build the containers the first time.

```
$ sudo docker-compose up -d
```

By default, your application will be available at

- https://localhost:4443
- http://localhost:8080

Check a container's logs:

```
$ sudo docker-compose logs container-name
```

For example, check Nginx logs:

```
$ sudo docker-compose logs nginx
```

Run artisan commands

```
$ sudo docker-compose run --rm artisan <command>
```

Install Composer dependencies

```
$ sudo docker-compose run --rm composer install
```

Install NPM dependencies

```
$ sudo docker-compose run --rm --entrypoint npm npm install
```

Restart a container:

```
$ sudo docker-compose restart <container-name>
```

Rebuild the containers:

```
$ sudo docker-compose build
```

## 4. Container Specific Instructions

### 4.1 PHP

#### 4.1.1 Setup xdebug for PHPStorm

In PHPStorm go to: `Languages & Frameworks` > `PHP` > `Servers` > and set the following settings:

![PHPStorm configuration](https://i.imgur.com/b8MwViH.png)

The name field must match `PHP_SERVER_NAME` (set to `laravel` by default). The host is set to `localhost`, the port
to the HTTP port, which is 8080 by defaut. The paths mappings are set appropriately.

If you are using Windows or MacOS, in the Docker-compose, you can add the following environment variable:

```
XDEBUG_CONFIG: "remote_host=host.docker.internal"
```

### 4.2 MySQL

#### 4.2.1 Import a dump

First, remove the existing volumes:

```
$ sudo docker-compose down -v
```

Then place your MySQL dump file in the `docker/mysql` folder, and start the containers normally.

### 4.3 NPM

#### 4.3.1 Hot Module Reload

Make sure your .js files load using the `mix` helper as shown here:

```
<script src="{{ mix('js/app.js') }}" defer></script>
```

#### 4.3.2 Browsersync

Add the following to your Blade layout:

```
@if(config('app.env') === 'local')
    <script async src='https://localhost:3000/browser-sync/browser-sync-client.js'></script>
@endif
```

## 5. Available Parameters

| Parameter Name         | Default Value      | Description                                                                                                     |
|------------------------|--------------------|-----------------------------------------------------------------------------------------------------------------|
| COMPOSE_PROJECT_NAME   | APP_NAME           | Sets the project name. This value is prepended along with the service name to the container on start up.        |
| COMPOSE_PATH_SEPARATOR | :                  | If set, the value of the COMPOSE_FILE environment variable is separated using this character as path separator. |
| COMPOSE_FILE           | docker-compose.yml | Specify the path to a Compose file.                                                                             |
| NGINX_HTTPS_PORT       | 4443               | HTTPS port of the Nginx container. Accessible at https://localhost:4443                                         |
| NGINX_HTTP_PORT        | 8080               | HTTP port of the Nginx container. Accessible at http://localhost:8080                                           |
| PHPMYADMIN_PORT        | 8081               | HTTP port of the phpMyAdmin container. Accessible at http://localhost:8081                                      |
| WEBPACK_PORT           | 4444               | Webpack port, used to serve JavaScript files with the `mix` helper function.                                    |
| MAILHOG_PORT           | 8025               | HTTP port of the MailHog container. Accessible at http://localhost:8025                                         |
| BROWSERSYNC_PORT       | 3000               | HTTP port of the Browsersync service of the NPM container                                                       |
| BROWSERSYNC_ADMIN_PORT | 3001               | HTTP port of the Browsersync admin panel of the NPM container Accessible at https://localhost:3001              |
| PHP_VERSION            | 7.4                | PHP Version. Can be one of: 7.2, 7.3, 7.4                                                                       |
| PHP_SERVER_NAME        | laravel            | PHP Server Name, used for xdebug                                                                                |
| USER_ID                | 1000               | Linux User ID for file and folder permissions                                                                   |
| GROUP_ID               | 1000               | Linux Group ID for file and folder permissions                                                                  |
| MIX_MODE               | watch              | Laravel Mix mode. Can be one of: watch, hot, dev, prod.                                                         |
| MIX_BROWSERSYNC        | disabled           | Enable Browsersync (enabled or disabled)                                                                        |

## 6. Q&A

1. Why use this over Laradock?

I respect Laradock's maintainers work, their solution works well for many people, 
but I find it to be very heavy as it tries to cover every possible use case. I wanted to create a lighter solution
that would be easy to modify, be closer to a "vanilla" Docker-compose installation and would only include what is 
necessary (Laradock supports [GitLab](https://github.com/laradock/laradock/tree/master/gitlab), 
how is that relevant to Laravel? Is a [1,700 lines](https://github.com/laradock/laradock/blob/master/docker-compose.yml) 
long Docker-compose file necessary?).

2. Why version the Docker files?

I think this approach makes sense if you want to customize your local environment, like if you want to add a container,
modify a Dockerfile, change an entrypoint... I played a bit with Git submodules, but I found that you have to explicitly
tell Git to fetch them when cloning a repo: this creates an extra step when setting up the project.

Moreover, submodules are not updated automatically; a trivial change in a Dockerfile
would result in a mess unless you fork the Git submodule repo by yourself but that creates more friction.

3. Why not create a package?

To install a PHP package, you need Composer. To run PHP files, you need PHP. But this solution aims to avoid installing Composer and/or PHP on your host to begin with. Thus it makes no sense to require Composer and PHP to install a package that aims to provide Composer and PHP.

4. Permission issue!

Make sure your `USER_ID` and `GROUP_ID` environment variables match your current user. Then, in your project's folder, 
do `chown -R $(id -u):$(id -g) . && chmod -R 755 .`
