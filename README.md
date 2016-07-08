Docker container with Ubuntu 16.04, RbEnv, Ruby, Nginx, Passenger, PostgreSQL and Redis.

## To build:
```
docker build -t dev:rails .
```

## To run:
```
docker run -t -i /my/code/dir:/app dev:rails
```
