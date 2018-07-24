FROM rocker/binder:3.4.2

# Note `## If extending this image, remember to switch back to USER root to apt-get`
# at the end of https://github.com/rocker-org/binder/blob/master/3.4.2/Dockerfile


# Trying to merge the Dockerfiles from: 
# https://github.com/binder-examples/dockerfile-rstudio/blob/master/Dockerfile
# https://github.com/rocker-org/binder/blob/master/3.4.2/Dockerfile
# into something that works to install the perl modules Circos needs



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
# Install EMBOSS
&& apt-get install -y emboss \
#
# Install Erpin
&& wget -L http://rna.igmors.u-psud.fr/download/Erpin/erpin5.5.4.serv.tar.gz; tar xzvf erpin5.5.4.serv.tar.gz; cp erpin5.5.4.serv/bin/erpin /usr/local/bin/ \
#
# Install tbl2asn
#&& wget ftp://ftp.ncbi.nih.gov/toolbox/ncbi_tools/converters/by_program/tbl2asn/linux.tbl2asn.gz; gunzip linux.tbl2asn.gz; chmod 755 linux.tbl2asn; cp linux.tbl2asn /usr/local/bin/tbl2asn \
# WILL NEED TO HANDLE tbl2asn DIFFERENTLY TOO BECAUSE CANNOT GET VIA BINDER
#
############################
# Install internal progam #
############################
#
# Install PirObject
&& git clone https://github.com/prioux/PirObject.git; cp PirObject/lib/PirObject.pm /etc/perl/ \
#
# Install all PirModels
&& git clone https://github.com/BFL-lab/PirModels.git; mv PirModels /root/ \
#
# Install flip
&& git clone https://github.com/BFL-lab/flip.git; cd flip/src/; gcc -o /usr/local/bin/flip flip.c \
#
# Install umac
&& git clone https://github.com/BFL-lab/umac.git; cp umac/umac /usr/local/bin/ \
#
# Install HMMsearchWC
&& git clone https://github.com/BFL-lab/HMMsearchWC.git; cp HMMsearchWC/HMMsearchCombiner /usr/local/bin/; cp HMMsearchWC/HMMsearchWrapper /usr/local/bin/ \
#
# Install RNAfinder
&& git clone https://github.com/BFL-lab/RNAfinder.git;


# Copy repo into ${HOME}, make user own $HOME
#USER root
COPY . ${HOME}
RUN chown -R ${NB_USER} ${HOME}
USER ${NB_USER}
