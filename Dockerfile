FROM jenkins/agent:latest-alpine-jdk11

USER root
WORKDIR /

LABEL maintainer="jesse@weisner.ca, chriswood.ca@gmail.com"
LABEL build_id="1680638726"

COPY banner.txt /etc/motd
COPY 99-zmotd.sh /docker-entrypoint.d/

RUN apk add --no-cache \
  tzdata \
  libcap \
  vault \
  ruby \
  python3 \
  py3-pip \
  jq \
  openldap-clients \
  curl \
  wget \
  coreutils \
  zip \
  whois \
  && setcap -r /usr/sbin/vault

# Add docker-entrypoint script base
ADD https://github.com/itsbcit/docker-entrypoint/releases/download/v1.5/docker-entrypoint.tar.gz /docker-entrypoint.tar.gz
RUN tar zxvf docker-entrypoint.tar.gz && rm -f docker-entrypoint.tar.gz \
 && chmod -R 555 /docker-entrypoint.* \
 && echo "UTC" > /etc/timezone \
 && ln -sf /usr/share/zoneinfo/UTC /etc/localtime \
 && chmod 664 /etc/passwd \
              /etc/group \
              /etc/shadow \
              /etc/timezone \
              /etc/localtime \
 && chown 0:0 /etc/shadow \
 && chmod 775 /etc

# Add Tini
ADD https://github.com/krallin/tini/releases/download/v0.19.0/tini-static-amd64 /tini
RUN chmod +x /tini \
 && ln -s /tini /sbin/tini 

USER jenkins
WORKDIR /home/jenkins
ENV TZ=America/Vancouver


ENTRYPOINT ["/tini", "--", "/docker-entrypoint.sh"]

CMD ["jshell"]
