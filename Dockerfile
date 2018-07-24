FROM rocker/binder:3.4.2

# Note `## If extending this image, remember to switch back to USER root to apt-get`
# at the end of https://github.com/rocker-org/binder/blob/master/3.4.2/Dockerfile


# Trying to merge the Dockerfiles from: 
# https://github.com/binder-examples/dockerfile-rstudio/blob/master/Dockerfile
# https://github.com/rocker-org/binder/blob/master/3.4.2/Dockerfile
# into something that works to install the perl modules Circos needs

# Copy repo into ${HOME}, make user own $HOME
USER root
COPY . ${HOME}
RUN chown -R ${NB_USER} ${HOME}
USER ${NB_USER}
# copied the repo now because I'll need to eventually referecne BLAST matrices files 
# during install
# Return to root for installation until end of it.

USER root

# Install requested tools
RUN apt-get update && apt-get install -y  git \
                       gcc-multilib \
                       build-essential \
                       apt-utils \
                       perl \
                       expat \
                       libexpat-dev \
                       cpanminus \
                       wget \
                       libglib2.0-dev \
                       autotools-dev \
                       automake \
                       aclocal \
# <---Put these throughout instead of spaces because got warning about continuation lines and https://github.com/moby/moby/pull/34333 suggest comments shouldn't count
#
############################
# Install perl dependency  #
############################
&& cpanm LWP::UserAgent.pm \
&& cpanm Bio::AlignIO
#
############################
# Install external progam  #
############################
# Create a directory for all git directories
WORKDIR git_repositories

# Install Blast
RUN apt-get install -y ncbi-blast+ \
#
# Install HMMER
&& apt-get install -y hmmer
#
# Install Exonerate
RUN git clone https://github.com/nathanweeks/exonerate.git
WORKDIR exonerate
RUN git checkout v2.4.0; ./configure; make; make check;autoreconf -f -i; make install
WORKDIR git_repositories

# Install Muscle
RUN wget -L http://www.drive5.com/muscle/downloads3.8.31/muscle3.8.31_i86linux32.tar.gz; tar xzvf muscle3.8.31_i86linux32.tar.gz;mv muscle3.8.31_i86linux32 /usr/local/bin/muscle; rm -rf /muscle3.8.31_i86linux32.tar.gz \
#
