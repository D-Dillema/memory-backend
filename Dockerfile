FROM php:alpine

RUN apk add --no-cache curl

# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

ENV COMPOSER_ALLOW_SUPERUSER 1

WORKDIR /usr/src/memory-backend

# Copy only the composer first to improve caching
COPY composer.json composer.lock ./

RUN composer install --no-scripts --no-autoloader

# Copy the rest of the application
COPY . .

# Run Composer scripts to generate autoload files
RUN composer dump-autoload --optimize

# Create volume for the database
VOLUME [ "/usr/src/memory-backend/var" ]

# Create the database (shouldn't really be used in production environments)
RUN ["php", "bin/console", "doctrine:schema:update", "--force"]

# Run the application
CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]

# Expose the application port
EXPOSE 8000
