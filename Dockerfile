FROM php:8.4-cli
WORKDIR /app
COPY api /app/api
CMD ["sh", "-c", "php -S 0.0.0.0:${PORT:-8000} -t api/public api/public/index.php"]