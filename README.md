# nginx-lets-encrypt-proxy

This proxy is incomplete. It currently parses the configuration and reloads nginx, but let's encrypt obtaining is not yet implemented. DON'T USE, or send a PR =)

Currently i have moved to https://github.com/NginxProxyManager

This is a docker container as a nginx proxy with Let's Encrypt and virtual hosts support.

Inspirations:

* https://github.com/gilyes/docker-nginx-letsencrypt-sample
* https://ilhicas.com/2019/03/02/Nginx-Letsencrypt-Docker.html
* https://github.com/Ilhicas/nginx-letsencrypt


Create necessary directories and files:

    mkdir ssl
    mkdir nginx/modules-enabled
    mkdir letsencrypt/
    touch letsencrypt/configured-domains


Create the dhparams:
    
    openssl dhparam -out ssl/dhparam.pem 2048


And then add your virtual hosts in `nginx/sites-enabled`, but make sure to use the following certificates:

    ssl_certificate /etc/letsencrypt/snake-oil/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/snake-oil/private-key.pem;

The internal scripts will then replace this and reload nginx when necessary.

Now add your domains as separate lines in `letsencrypt/configured-domains`.

Now build the image:

    docker-compose build --pull

And then start:

    docker-compose up
