# Laradose

Laradose aims to bring a light yet powerful and configurable Docker compose configuration to run a Laravel
application locally. It is not intended for production.

Out of the box, 6 containers are installed:

- MySQL
- PHP
- Nginx
- Artisan
- Composer
- NPM

1. [Requirements](#1-requirements)
2. [Installation Instructions](#1-installation-instructions)
   1. [Automated installation](#21-automated-installation)
   2. [Manual installation](#22-manual-installation)
3. [Usage](#3-usage)
   1. [Commands](#31-commands)
   2. [Adding additional containers](#32-adding-additional-containers)
4. [Q&A](#4-qa)

## 1. Requirements

- [Docker](https://docs.docker.com/engine/install//)
- [Docker Compose](https://docs.docker.com/compose/install/)

This was tested on Linux. It may or may not work on Windows or MacOS.

## 2. Installation Instructions

### 2.1 Automated installation

A bash script is provided to install Laradose automatically. It will add the required files to your project's folder
and help you configure Laradose. This is the preferred method. To use it, `cd` into your project's folder and run:

```
$ wget https://raw.githubusercontent.com/AdrienPoupa/laradose/master/laradose.sh && chmod +x laradose.sh
$ ./laradose.sh
```

### 2.2 Manual installation

You can install Laradose manually if you do not wish to use the script.

1. Copy the following into your project folder:
- The `docker` folder
- The `docker-compose.yml` file
2. Append the content of `.env` to your `.env` file
3. Set `DB_HOST=mysql` and `REDIS_HOST=redis`
4. Append the content of `webpack.mix.js` to your `webpack.mix.js` file

Set write permissions on the host

```
$ chmod -R 755 .
```

## 3. Usage

If you need to import a database dump, place it in the `docker/mysql` folder. It will be imported automatically when
the MySQL container boots.

### 3.1 Commands

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

For example, check Nginx's logs:

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

Remove the volumes (needed if you want to reimport the database)

```
$ sudo docker-compose down -v
```

Restart a container:

```
$ sudo docker-compose restart <container-name>
```

Rebuild the containers:

```
$ sudo docker-compose build
```

### 3.2 Adding additional containers

In addition to the 6 base containers, additional containers are offered:

- Redis
- Laravel Horizon
- Laravel Echo Server
- PHPMyAdmin

To add an additional container, modify your `.env`'s `COMPOSE_FILE` variable to add the path to the 
additional `docker-compose.override.yml` file. 

For example, to add Redis, do:

```
COMPOSE_FILE=docker-compose.yml:docker/redis/docker-compose.override.yml
```

## 4. Q&A

1. Why use this over Laradock?

I respect Laradock's maintainers work, their solution works well for many people, 
but I find it to be very heavy as it tries to cover every possible use case. I wanted to create a lighter solution
that would be easy to modify, be closer to a "vanilla" Docker-compose installation and would only include what is 
necessary (Laradock supports [GitLab](https://github.com/laradock/laradock/tree/master/gitlab), 
how is that relevant to Laravel? Is a [1,700 lines](https://github.com/laradock/laradock/blob/master/docker-compose.yml) 
long Docker-compose file necessary?).

2. Why version the Docker files?

I think this approach makes sense if you want to customize your local environment, like if you want to add a container,
modify a Dockerfile, change an entrypoint... I played a bit with Git submodules but I found that you have to explicitly
tell Git to fetch them when cloning a repo: this creates an extra step when setting up the project.

Moreover, submodules are not updated automatically and a trivial change in a Dockerfile
would result in a mess unless you fork the Git submodule repo by yourself but that creates more friction.