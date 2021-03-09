# SuiteCRM LTS 7.10 - Docker

A dockerized version of SuiteCRM LTS. <br>

An extended version, which includes MariaDB, can be found here: <br>
DockerHub: https://hub.docker.com/r/dutches/suitecrm-lts-standalone <br>
Github: https://github.com/Flying--Dutchman/docker-suitecrm-lts-7.10-mariadb <br>

# Ports
8080 - SuiteCRM 

# Volumes

It exposes multiple volumes for easy access.

All volume folders in one: /var/www/html/docker.d  
SuiteCRM upload folder: /var/www/html/upload  
SuiteCRM configuration: /var/www/html/docker.d/conf.d  
SuiteCRM logfile: /var/www/html/docker.d/log   
SuiteCRM custom folder: /var/www/html/custom  
Entire SuiteCRM folder (if needed): /var/www/html/
