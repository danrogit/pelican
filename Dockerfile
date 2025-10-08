FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
    curl zip unzip git sqlite3 libpng-dev libjpeg-dev libonig-dev libxml2-dev \
    libzip-dev libicu-dev libpq-dev libssl-dev nodejs npm \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd intl zip opcache \
    && npm install -g yarn

WORKDIR /var/www/html

COPY . /var/www/html

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install --no-dev --optimize-autoloader || true
RUN yarn install && yarn build || true

EXPOSE 80

# Added the missing healthcheck, which gave issues on boot.
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:80/ || exit 1

CMD ["php", "-S", "0.0.0.0:80", "-t", "public"]
