# Laravel Docker Compose

This repository aims to bring a light yet powerful and configurable Docker compose configuration to run a Laravel
application locally. It is not intended for production.

Out of the box, 6 containers are installed:

- MySQL
- PHP
- Nginx
- Artisan
- Composer
- NPM

## Installation Instructions

First, make sure [Docker Compose is installed](https://docs.docker.com/compose/install/) on your machine.

To install a Laravel application from scratch, proceed as follows:

Copy this repository's files:

Copy `.env.example` to `.env` or modify your existing `.env` after checking `.env.example` modifications
- The `DB_HOST` is set to `mysql`
- A new Docker section at the bottom is added

Replace your `webpack.mix.js` by this one, or add the new Docker sections.

Replace your `.gitignore` by this one, or add the new Docker sections.

If you need to import a database dump, place it in the `docker/mysql` folder. It will be imported automatically when
the MySQL container boots.

Build the containers

```
sudo docker-compose build
```

Install Composer dependencies

```
sudo docker-compose run --rm composer install
```

Install NPM dependencies

```
sudo docker-compose run --rm --entrypoint npm npm install
```

Generate application key

```
sudo docker-compose run --rm artisan key:generate
```

Set storage permissions on the host

```
chmod -R 755 storage
```

## Usage

Run the project

```
sudo docker-compose run -d
```

By default, your application will be available at

- https://localhost:4443
- http://localhost:8080

Check a container's logs:

```
sudo docker-compose logs container-name
```

For example, check Nginx's logs:

```
sudo docker-compose logs nginx
```

Run artisan commands

```
sudo docker-compose run --rm artisan my-command
```

For example, migrate your database:

```
sudo docker-compose run --rm artisan migrate
```

Remove the database (needed if you want to reimport)

```
sudo docker-compose down -v
```

Restart a container:

```
sudo docker-compose restart container-name
```

For example, to restart PHP:

```
sudo docker-compose restart php
```

### Adding additional containers

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
