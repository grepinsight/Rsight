FROM rocker/verse:latest
MAINTAINER Albert Lee grepinsight@gmail.com


RUN dpkg -l | grep 'atlas\|blas'

RUN update-alternatives --get-selections | grep libblas

RUN apt-get update \
	&& apt-get install libopenblas-dev \
	&& apt-get install -y --no-install-recommends apt-utils ed libnlopt-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/

RUN update-alternatives --get-selections | grep libblas

# Set up
RUN mkdir -p $HOME/.R \
    && echo "CXX14FLAGS=-O3 -march=native -mtune=native -DBOOST_NO_AUTO_PTR" >> /root/.R/Makevars \
    && echo "CXX14FLAGS += -fPIC" >> /root/.R/Makevars

RUN cat $HOME/.R/Makevars

# Install rstan
RUN install2.r --error --deps TRUE \
    rstan \
	devtools \
	testthat \
	docopt \
	futile.logger \
	tictoc \
    ggbeeswarm \
    caret \
    e1071 \
    ggrepel \
    latex2exp \
    bookdown \
	rmdformats \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Add Lastpass
RUN apt-get update && \
	apt-get --no-install-recommends -yqq install \
	  bash-completion \
	  build-essential \
   cmake \
  libcurl3  \
  libcurl3-openssl-dev  \
  libssl1.0 \
  libssl1.0-dev \
  libxml2 \
  libxml2-dev  \
  pkg-config \
  ca-certificates \
  xclip

RUN git clone https://github.com/lastpass/lastpass-cli.git && \
	cd lastpass-cli && \
	make && make install


COPY user-settings /

RUN mv /user-setting /home/rstudio/user-settings

# Global site-wide config -- neeeded for building packages
# RUN mkdir -p $HOME/.R/ \
#     && echo "CXXFLAGS=-O3 -mtune=native -march=native -Wno-unused-variable -Wno-unused-function -flto -ffat-lto-objects  -Wno-unused-local-typedefs \n" >> $HOME/.R/Makevars

