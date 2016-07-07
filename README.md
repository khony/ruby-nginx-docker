# ruby-nginx-docker

Docker container with Ubuntu 16.04, RbEnv, Ruby, Nginx, Passenger, PostgreSQL and Redis.

To build:
docker build -t container_name .

To run:
docker run -v /my/code/dir:/src container_name
