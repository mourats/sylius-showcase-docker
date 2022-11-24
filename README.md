# Sylius Showcase
This Docker image is a showcase of the [Sylius](https://sylius.com/) e-commerce platform. 

This uses Ubuntu20.04 as the base image and installs the latest version of Sylius on it.

It uses supervisord to run the following services all in one Docker container:
- PHP-FPM
- Nginx
- MariaDB

## Setup
`docker run -v $(pwd)/media:/app/public/media --rm -d -p 80:80 sylius-showcase`

### Add example data
`docker exec -it <container-id> bin/console sylius:fixtures:load`