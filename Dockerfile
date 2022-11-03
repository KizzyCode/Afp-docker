FROM ubuntu:latest

ENV APT_PACKAGES gettext jq supervisor netatalk
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get upgrade --yes \
    && apt-get install --yes ${APT_PACKAGES} \
    && apt-get autoremove --yes \
    && apt-get clean

COPY ./files/afp.conf /etc/netatalk/afp.conf
COPY ./files/afp.conf.user-template /etc/netatalk/afp.conf.user-template
COPY ./files/supervisord.conf /etc/netatalk/supervisord.conf
COPY ./files/start.sh /usr/libexec/start.sh

USER root
CMD [ "/usr/libexec/start.sh" ]
