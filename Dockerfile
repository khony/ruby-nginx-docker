FROM ubuntu:16.04

MAINTAINER FABIO

# Install packages for building ruby
RUN apt-get update
RUN apt-get install -y --force-yes build-essential curl git
RUN apt-get install -y --force-yes zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt-dev
RUN apt-get install -y --force-yes libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev
RUN gpg --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
RUN gpg --armor --export 561F9B9CAC40B2F7 | apt-key add -
RUN apt-get install -y --force-yes apt-transport-https
RUN sh -c "echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger xenial main' >> /etc/apt/sources.list.d/passenger.list"
RUN chown root: /etc/apt/sources.list.d/passenger.list
RUN chmod 600 /etc/apt/sources.list.d/passenger.list
RUN sed -i 's/archive.ubuntu.com/55.archive.ubuntu.com/g' /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y --force-yes nginx-full passenger
RUN apt-get install -y --force-yes libpq-dev
RUN apt-get install -y --force-yes nodejs
RUN apt-get install -y --force-yes imagemagick
RUN apt-get install -y --force-yes redis-server
RUN echo "#!/bin/sh\nexit 101" > /usr/sbin/policy-rc.d; chmod +x /usr/sbin/policy-rc.d
RUN apt-get -qy install language-pack-en
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales
RUN LC_ALL=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get -y install postgresql-server-dev-all postgresql postgresql-contrib sudo
RUN apt-get clean

USER postgres
RUN /etc/init.d/postgresql start \
    && psql --command "CREATE USER pguser WITH SUPERUSER PASSWORD 'pguser';" \
    && createdb -O pguser pgdb

USER root
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.5/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.5/main/postgresql.conf

# Install NGINX
ADD ./nginx.conf /etc/nginx.conf
ADD ./start_services /usr/local/bin

# Install rbenv and ruby-build
RUN git clone https://github.com/sstephenson/rbenv.git /root/.rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build
RUN /root/.rbenv/plugins/ruby-build/install.sh
ENV PATH /root/.rbenv/bin:$PATH
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh # or /etc/profile
RUN echo 'eval "$(rbenv init -)"' >> .bashrc
RUN chmod +x /etc/profile.d/rbenv.sh
# RUN rbenv install 2.1.2

# Install multiple versions of ruby
ENV CONFIGURE_OPTS --disable-install-doc

# Install Bundler for each version of ruby
RUN echo 'gem: --no-rdoc --no-ri' >> /.gemrc

RUN mkdir -p /var/run/postgresql && chown -R postgres /var/run/postgresql
VOLUME ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]
VOLUME /app

EXPOSE 80
EXPOSE 3000
EXPOSE 5432

CMD ["/usr/local/bin/start_services"]

ENTRYPOINT ["/bin/bash"]
