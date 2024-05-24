FROM jenkins/agent:latest-alpine-jdk11

ARG OC_VERSION=4.10
USER root
WORKDIR /

LABEL maintainer="jesse@weisner.ca, chriswood.ca@gmail.com"
LABEL build_id="1716570297"

COPY banner.txt /etc/motd
COPY 99-zmotd.sh /docker-entrypoint.d/

RUN apk add --no-cache \
  tzdata \
  libcap \
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
  gcompat \
  bind-tools 

RUN apk add --no-cache \
  vault --repository=https://dl-cdn.alpinelinux.org/alpine/v3.18/community \
  && setcap -r /usr/sbin/vault

RUN apk add --no-cache \
  minio-client \
  yq \
  --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community

RUN curl -sLo /tmp/oc.tar.gz https://mirror.openshift.com/pub/openshift-v$(echo $OC_VERSION | cut -d'.' -f 1)/clients/ocp/stable-$OC_VERSION/openshift-client-linux.tar.gz && \
    tar xzvf /tmp/oc.tar.gz -C /usr/local/bin/ && \
    rm -rf /tmp/oc.tar.gz

RUN curl -sLo /tmp/pup.zip https://github.com/ericchiang/pup/releases/download/v0.4.0/pup_v0.4.0_linux_amd64.zip && \
    unzip -d /usr/local/bin/ /tmp/pup.zip && \
    rm -rf /tmp/pup.zip

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


COPY 50-start-dockerd.sh /docker-entrypoint.d/
USER root
RUN apk add --no-cache \
  docker \
  && unset DOCKER_HOST




USER jenkins
WORKDIR /home/jenkins
ENV TZ=America/Vancouver

ENTRYPOINT ["/tini", "--", "/docker-entrypoint.sh"]

CMD ["jshell"]
