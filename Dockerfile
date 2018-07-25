FROM rocker/binder:3.4.2

# Note `## If extending this image, remember to switch back to USER root to apt-get`
# at the end of https://github.com/rocker-org/binder/blob/master/3.4.2/Dockerfile


# Trying to merge the Dockerfiles from: 
# https://github.com/binder-examples/dockerfile-rstudio/blob/master/Dockerfile
# https://github.com/rocker-org/binder/blob/master/3.4.2/Dockerfile
# into something that works to install all the items that MFannot needs


# copied the repo now because I'll need to eventually reference BLAST matrices files 
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
                       automake
# <---Put these throughout instead of spaces because got warning about continuation lines and https://github.com/moby/moby/pull/34333 suggest comments shouldn't count
#
############################
# Install perl dependency  #
############################
#&& cpanm LWP::UserAgent.pm \
#&& cpanm Bio::AlignIO
#
############################
# Install external progam  #
############################
# Create a directory for all git directories
WORKDIR git_repositories


#
####################
# Set ENV variable #
####################
#
#ENV RNAFINDER_CFG_PATH /
#ENV MF2SQN_LIB /mf2sqn/lib/
#ENV MFANNOT_LIB_PATH /MFannot_data/protein_collections/
#ENV MFANNOT_EXT_CFG_PATH /MFannot_data/config
#ENV MFANNOT_MOD_PATH /MFannot_data/models/
#ENV BLASTMAT /BLASTMAT/
#ENV EGC /MFannot_data/EGC/
#ENV ERPIN_MOD_PATH /MFannot_data/models/Erpin_models/
#ENV PIR_DATAMODEL_PATH /PirModels
#
#
# Putting this at end because usally block with it above is at end but I wanted to copy repo earlier so could deal with matrices files
# Copy repo into ${HOME}, make user own $HOME
USER root
COPY . ${HOME}
RUN chown -R ${NB_USER} ${HOME}
USER ${NB_USER}