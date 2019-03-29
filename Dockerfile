FROM ruby:2.6.1

LABEL maintainer="Michael Senn <michael@morrolan.ch>"

EXPOSE 8080

# Has to be changed if texlive were to update.
ENV PATH "$PATH:/usr/local/texlive/2018/bin/x86_64-linux"

RUN apt-get -y update && apt-get -y dist-upgrade && apt-get -y autoremove && apt-get -y install ghostscript
# Pain in the behind, but significantly smaller than Debian's texlive-full
# which weighs in at 2 GB.
COPY texlive.profile /tmp/
RUN cd /tmp \
 && curl -L -O http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz \
 && tar xfvz install-tl-unx.tar.gz \
 && rm install-tl-unx.tar.gz \
 && cd install-tl-20190227 \
 && ./install-tl --profile=/tmp/texlive.profile \
 && tlmgr install standalone

RUN gem install bundler

# Tiny Init. (Reap zombies, forward signals)
ENV TINI_VERSION v0.17.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

# Create non-privileged user
RUN groupadd -r emerald && useradd -r -g emerald emerald

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
# Throw error if Gemfile was modified after Gemfile.lock
RUN bundle config --global frozen 1
# Installing gems before copying source allows caching of gem installation.
COPY Gemfile Gemfile.lock /usr/src/app/
ARG BUNDLE_EXCLUDE_GROUPS="development test"
RUN bundle install --without $BUNDLE_EXCLUDE_GROUPS
COPY . /usr/src/app

RUN chmod +x "./docker-entrypoint.sh"

USER emerald
ENTRYPOINT ["/tini", "--", "./docker-entrypoint.sh"]
