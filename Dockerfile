FROM centos:7
LABEL maintainer="jindrich.skupa@enrian.com"

ENV LANG=en_US.UTF-8
ENV JRUBY_VERSION 9.1.14.0
ENV PATH /opt/jruby/bin:$PATH
ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_PATH="$GEM_HOME" \
	BUNDLE_BIN="$GEM_HOME/bin" \
	BUNDLE_SILENCE_ROOT_WARNING=1 \
	BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH $BUNDLE_BIN:$PATH

RUN curl --silent --location https://rpm.nodesource.com/setup_8.x | bash - \
	&& curl --output /usr/local/bin/phantomjs https://s3.amazonaws.com/circle-downloads/phantomjs-2.1.1 \
	&& yum update -y \
	&& yum install -y libpng12 libjpeg-turbo wget git curl nodejs sudo \
	&& yum clean all \
  && rm -f /etc/localtime && ln -s /usr/share/zoneinfo/Europe/Prague /etc/localtime \
	&& localedef -v -c -i en_US -f UTF-8 en_US.UTF-8 || true \
	&& wget https://dist.stg.enrian.com/pkgs/jdk-8u131-linux-x64.rpm && rpm -Uvh jdk-8u131-linux-x64.rpm \
  && rm -f jdk-8u131-linux-x64.rpm \
  && mkdir /opt/jruby \
  && curl -fSL https://s3.amazonaws.com/jruby.org/downloads/${JRUBY_VERSION}/jruby-bin-${JRUBY_VERSION}.tar.gz -o /tmp/jruby.tar.gz \
  && tar -zx --strip-components=1 -f /tmp/jruby.tar.gz -C /opt/jruby \
	&&  mkdir -p /opt/jruby/etc \
	&& { \
		echo 'install: --no-document'; \
		echo 'update: --no-document'; \
	} >> /opt/jruby/etc/gemrc \
	&& gem install bundler rake net-telnet xmlrpc \
  && mkdir -p "$GEM_HOME" "$BUNDLE_BIN" \
	&& chmod 777 -R "$GEM_HOME" "$BUNDLE_BIN"

RUN groupadd --gid 3434 circleci \
  && useradd --uid 3434 --gid circleci --shell /bin/bash --create-home circleci \
	&& echo >> /etc/sudoers \
  && echo 'circleci ALL=NOPASSWD: ALL' >> /etc/sudoers

USER circleci

CMD [ "irb" ]
