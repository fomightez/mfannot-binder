FROM rocker/binder:3.4.2

# Note `## If extending this image, remember to switch back to USER root to apt-get`
# at the end of https://github.com/rocker-org/binder/blob/master/3.4.2/Dockerfile

USER root



# Install compiler and perl stuff
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
     gcc-multilib \
     apt-utils \
     perl \
     expat \
     libexpat-dev \
     cpanminus \
     libarchive-zip-perl \
     libdbd-mysql \
     libdbd-mysql-perl \
     libdbd-pgsql \
     libgd-gd2-perl \
     libgd2-noxpm-dev \
     libpixman-1-0 \
     libpixman-1-dev \
     graphviz \
     libxml-parser-perl \
     libsoap-lite-perl \
     libxml-libxml-perl \
     libxml-dom-xpath-perl \
     libxml-libxml-simple-perl \
     libxml-dom-perl



# Install perl modules 
RUN cpanm CPAN::Meta \
 readline \ 
 Term::ReadKey \
 YAML \
 Digest::SHA \
 Module::Build \
 ExtUtils::MakeMaker \
 Test::More \
 Data::Stag \
 Config::Simple \
 Statistics::Lite 

# Copy repo into ${HOME}, make user own $HOME
USER root
COPY . ${HOME}
RUN chown -R ${NB_USER} ${HOME}
USER ${NB_USER}


