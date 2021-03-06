FROM registry.centos.org/centos/centos:7

MAINTAINER Jean-Francois Chevrette <jfchevrette@gmail.com>

# Labels consumed by the build service
LABEL Component="mattermost" \
      Name="mattermost/mattermost-team-4.10.1-centos7" \
      Version="4.10.1" \
      Release="1"

# Openshift/Kubernetes labels
LABEL io.k8s.description="Mattermost is an open source, self-hosted Slack-alternative" \
      io.k8s.display-name="Mattermost 4.10.1" \
      io.openshift.expose-services="8065/tcp:mattermost" \
      io.openshift.non-scalable="true" \
      io.openshift.tags="mattermost,slack" \
      io.openshift.min-memory="128Mi"

RUN set -x && \
  yum -y install epel-release && \
  yum -y install jq nc tar && \
  yum clean all

# Install little pcp pmcd server for metrics collection
# would prefer only pmcd, and not the /bin/pm*tools etc.
COPY pcp.repo /etc/yum.repos.d/pcp.repo
RUN yum install -y pcp && yum clean all && \
    mkdir -p /etc/pcp /var/run/pcp /var/lib/pcp /var/log/pcp && \
    chown -R 1000 /etc/pcp /var/run/pcp /var/lib/pcp /var/log/pcp && \
    chmod -R ug+rw /etc/pcp /var/run/pcp /var/lib/pcp /var/log/pcp

EXPOSE 44321

ENV MATTERMOST_VERSION 4.10.1

RUN set -x && \
  curl -sLO https://releases.mattermost.com/${MATTERMOST_VERSION}/mattermost-team-${MATTERMOST_VERSION}-linux-amd64.tar.gz && \
  tar -xf mattermost-team-${MATTERMOST_VERSION}-linux-amd64.tar.gz -C /opt && \
  rm -f mattermost-team-${MATTERMOST_VERSION}-linux-amd64.tar.gz && \

  mkdir /opt/mattermost/data && \

  cp -f /opt/mattermost/config/config.json /opt/mattermost/config.json.orig && \

  chown -R 1001 /opt/mattermost && \
  chmod 777 /opt/mattermost/data /opt/mattermost/logs

COPY docker-entrypoint.sh /
COPY mattermost+pmcd.sh /

USER 1001

EXPOSE 8065

ENTRYPOINT ["/mattermost+pmcd.sh"]
CMD ["mattermost"]
