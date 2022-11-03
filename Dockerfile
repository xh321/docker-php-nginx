FROM ubuntu:20.04
LABEL Maintainer="XiaoHe321 <xiaohe321@Outlook.com>"
LABEL Description="Lightweight container with Nginx 1.22 & PHP 8.1 based on Ubuntu."
# Setup document root
WORKDIR /var/www/html

# Install packages and remove default server definition
RUN export LC_ALL=C.UTF-8 && \
  export DEBIAN_FRONTEND="noninteractive" && \
  apt update && \ 
  apt install -y software-properties-common && \
  add-apt-repository ppa:ondrej/nginx && \
  add-apt-repository ppa:ondrej/php && \
  apt install -y \
  gnupg \
  curl \
  nginx \
  php8.1 \
  php8.1-ctype \
  php8.1-curl \
  php8.1-dom \
  php8.1-fpm \
  php8.1-gd \
  php8.1-intl \
  php8.1-mbstring \
  php8.1-mysqli \
  php8.1-opcache \
  php8.1-phar \
  php8.1-xml \
  php8.1-xmlreader \
  supervisor

# Create symlink (if not exist) so programs depending on `php` still function
RUN [ -f "/usr/bin/php" ] || ln -s /usr/bin/php8.1 /usr/bin/php

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php/8.1/php-fpm.d/www.conf
COPY config/php.ini /etc/php/8.1/conf.d/custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
#RUN chown -R nobody.nobody /var/www/html /run /var/lib/nginx /var/log/nginx

# Switch to use a non-root user from here on
#USER nobody

# Add application
COPY src/ /var/www/html/

# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
