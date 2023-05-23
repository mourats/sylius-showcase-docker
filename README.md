# Sylius Showcase Docker
This Docker image is a showcase of the [Sylius](https://sylius.com/) e-commerce platform. It comes with development dependencies but the Symfony Web Profiler's debug toolbar is disabled by default.

This uses Ubuntu 20.04 as the base image and installs the latest version of Sylius on it.

It uses supervisord to run the following services all in one Docker container:
- PHP-FPM
- Nginx
- MariaDB

## Setup
First build the docker image:
```sh
docker build --platform linux/amd64 -t sylius-showcase .
```

And then run a docker container with the image:
```sh
docker run -v $(pwd)/media:/app/public/media -d --restart=always -p 8080:80 --name 'sylius' sylius-showcase
```
>The **./media** volume is exposed for the container. We will give write permission for this folder.
>The **restart** flag is actived. The container will start again if the host machine power off.
>The container is named as **'sylius'**.


### Add example data
```sh
docker exec -it sylius bin/console sylius:fixtures:load -n && sudo chown -R 33:33 media
```
>This chown permit the container to write in the media folder.
>The example data will be loaded.

## View the web shop
Visit http://localhost:8080/ to view the shop's frontend.
Visit http://localhost:8080/admin to view the admin-view.

### Login
_Default credentials:_  
Username: `sylius`  
Password: `sylius`  