FROM nginx:alpine
RUN apk add bash inotify-tools certbot openssl ca-certificates
RUN mkdir -p /var/www/certbot/
RUN mkdir -p /etc/ssl/
WORKDIR /opt
COPY certbot-obtain.sh certbot-obtain.sh
COPY certbot-renewal.sh certbot-renewal.sh
COPY nginx-reload.sh nginx-reload.sh
COPY entrypoint.sh entrypoint.sh
COPY default.conf /etc/nginx/nginx.conf
RUN chmod +x certbot-obtain.sh && chmod +x certbot-renewal.sh && chmod +x nginx-reload.sh && chmod +x entrypoint.sh 
ENTRYPOINT ["./entrypoint.sh"]