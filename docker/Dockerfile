FROM ubuntu:16.04
MAINTAINER Patrick Debois <Patrick.Debois@jedi.be>

RUN apt-get -qy update

# Install neccesary packages for compilation
RUN apt-get -qy install build-essential ruby-dev zlib1g-dev
RUN apt-get -qy install rubygems

RUN gem install markdown2confluence

# Clean apt cache
RUN apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* \
    rm -rf /var/cache/*.tar.gz \
    rm -rf /var/cache/*/*.tar.gz

ENTRYPOINT ["/usr/local/bin/markdown2confluence"]
