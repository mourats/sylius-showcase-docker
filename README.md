# Sylius Showcase
This Docker image is a showcase of the [Sylius](https://sylius.com/) e-commerce platform. It comes with development dependencies but the Symfony Web Profiler's debug toolbar is disabled by default.

This uses Ubuntu 20.04 as the base image and installs the latest version of Sylius on it.

It uses supervisord to run the following services all in one Docker container:
- PHP-FPM
- Nginx
- MariaDB

## Setup
Most basic startup:
`docker run --rm -d -p 8080:80 abjorkland/sylius-showcase`

Expose a volume for the container:
`docker run -v $(pwd)/media:/app/public/media --rm -d -p 8080:80 abjorkland/sylius-showcase`
>This is useful for when you want to write assets, such as loading example data into Sylius. 

### Add example data
`docker exec -it <container-id> bin/console sylius:fixtures:load`
> The _container-id_ may be the name that you or docker assigns the container, or the hash-ID.  
> Using the first 4 characters of the hash is often enough!

## View the web shop
Visit http://localhost:8080/ to view the shop's frontend.
Visit http://localhost:8080/admin to view the admin-view.

### Login
_Default credentials:_  
Username: `sylius`  
Password: `sylius`  