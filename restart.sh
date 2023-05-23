#!/bin/bash
docker exec -it sylius bin/console sylius:fixtures:load -n
sudo chown -R 33:33 $(pwd)/media