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
                       automake \
                       autotools-dev \
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
&& wget ftp://ftp.ncbi.nih.gov/toolbox/ncbi_tools/converters/by_program/tbl2asn/linux.tbl2asn.gz; gunzip linux.tbl2asn.gz; chmod 755 linux.tbl2asn; cp linux.tbl2asn /usr/local/bin/tbl2asn \
#
############################
# Install internal progam #
############################
#
# Install PirObject
&& git clone https://github.com/prioux/PirObject.git; cp PirObject/lib/PirObject.pm /etc/perl/; \
#
# Install all PirModels
&& git clone https://github.com/BFL-lab/PirModels.git; mv PirModels /root/ \
#
# Install flip
&& git clone https://github.com/BFL-lab/flip.git; cd flip/src/; gcc -o /usr/local/bin/flip flip.c; \
#
# Install umac
&& git clone https://github.com/BFL-lab/umac.git; cp umac/umac /usr/local/bin/ \
#
# Install HMMsearchWC
&& git clone https://github.com/BFL-lab/HMMsearchWC.git; cp HMMsearchWC/HMMsearchCombiner /usr/local/bin/; cp HMMsearchWC/HMMsearchWrapper /usr/local/bin/ \
#
# Install RNAfinder
&& git clone https://github.com/BFL-lab/RNAfinder.git; cp RNAfinder/RNAfinder /usr/local/bin/; cp RNAfinder/DOT_RNAfinder.cfg ~/.RNAfinder.cfg \
#
# Install mf2sqn
&& it clone https://github.com/BFL-lab/mf2sqn.git; cp mf2sqn/mf2sqn /usr/local/bin/; cp mf2sqn/qualifs.pl /usr/share/perl5/ \
#
# Install grab-fasta
&& git clone https://github.com/BFL-lab/grab-fasta.git; cp grab-fasta/grab-fasta /usr/local/bin/;cp grab-fasta/grab-seq /usr/local/bin/ \
#
# Install MFannot
&& git clone https://github.com/BFL-lab/mfannot.git; cp mfannot/mfannot /usr/local/bin/;cp -r mfannot/examples / \
#
################
# Install data #
################
# Install data
&& git clone https://github.com/BFL-lab/MFannot_data.git
#
#Install BLAST matrix
WORKDIR BLASTMAT
WORKDIR git_repositories
# RUN mkdir BLASTMAT; cd BLASTMAT; wget  ftp://ftp.ncbi.nlm.nih.gov/blast/matrices/* ; cd ..
# THis will need to be done with COPY I think once, I put matrices files in repo

WORKDIR git_repositories

#Copy RNAfinder config file
RUN cp ~/.RNAfinder.cfg / \
#
#mv PirModels 
&& mv /root/PirModels / 

####################
# Set ENV variable #
####################

ENV RNAFINDER_CFG_PATH /
ENV MF2SQN_LIB /mf2sqn/lib/
ENV MFANNOT_LIB_PATH /MFannot_data/protein_collections/
ENV MFANNOT_EXT_CFG_PATH /MFannot_data/config
ENV MFANNOT_MOD_PATH /MFannot_data/models/
ENV BLASTMAT /BLASTMAT/
ENV EGC /MFannot_data/EGC/
ENV ERPIN_MOD_PATH /MFannot_data/models/Erpin_models/
ENV PIR_DATAMODEL_PATH /PirModels


# Putting this at end because usally block with it above is at end but I wanted to copy repo earlier so could deal with matrices files
USER ${NB_USER}

