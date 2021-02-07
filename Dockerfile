FROM debian:buster

LABEL maintainer="eproveme@student.21-school.ru"

ENV TZ Europe/Moscow

RUN apt-get update -y && apt-get upgrade -y && \ 
	apt-get install -y \
	nginx \
	wordpress \
	php7.3 php-mysql php-fpm php-pdo php-gd php-cli php-mbstring \
	default-mysql-server \
	openssl

WORKDIR /var/www/html/

ADD https://files.phpmyadmin.net/phpMyAdmin/5.0.4/phpMyAdmin-5.0.4-all-languages.tar.gz phpMyAdmin.tar.gz
RUN	tar -xf phpMyAdmin.tar.gz && \
	rm -rf phpMyAdmin.tar.gz && \
	mv phpMyAdmin-5.0.4-all-languages /var/www/html/phpmyadmin

ADD https://wordpress.org/latest.tar.gz latest.tar.gz
RUN	tar -xvzf latest.tar.gz && \
	rm -rf latest.tar.gz

RUN openssl req -x509 -nodes -days 365 \
	-subj "/C=RU/ST=Moscow/L=Moscow/O=21school/OU=eproveme/CN=localhost/emailAddress=eproveme@student.21-school.ru" \
	-newkey rsa:2048 \
	-keyout /etc/ssl/nginx-selfsigned.key \
	-out /etc/ssl/certs/nginx-selfsigned.crt && openssl dhparam -out /etc/ssl/certs/dhparam.pem 512

COPY ./srcs/nginx.conf /etc/nginx/sites-enabled/
COPY ./srcs/wp-config.php /usr/share/wordpress/wp-config.php
COPY ./srcs/config.inc.php /var/www/html/phpmyadmin
RUN rm -rf index.nginx-debian.html
RUN cp -r /usr/share/wordpress /var/www/html

RUN chmod -R 600 /etc/ssl/*
RUN chown -R www-data /var/www/*
RUN chmod -R 755 /var/www/*

COPY ./srcs/launch.sh /usr/local/bin
COPY ./srcs/autoindex.sh /usr/local/bin

EXPOSE 80 443

CMD launch.sh