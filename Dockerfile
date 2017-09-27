FROM rabbitmq:3.6-management-alpine

ENV RABBITMQ_AUTOCLUSTER_VERSION 0.8.0

COPY docker-entrypoint.sh /usr/local/bin/
COPY update-hosts.sh /usr/local/bin

RUN apk update --no-cache && \
    apk add --no-cache ca-certificates wget curl jq && \
    update-ca-certificates

RUN chmod a+w /etc/hosts
RUN wget -q -O "${RABBITMQ_HOME}/plugins/autocluster-${RABBITMQ_AUTOCLUSTER_VERSION}.ez" "http://github.com/rabbitmq/rabbitmq-autocluster/releases/download/${RABBITMQ_AUTOCLUSTER_VERSION}/autocluster-${RABBITMQ_AUTOCLUSTER_VERSION}.ez" && \
    wget -q -O "${RABBITMQ_HOME}/plugins/rabbitmq_aws-${RABBITMQ_AUTOCLUSTER_VERSION}.ez" "http://github.com/rabbitmq/rabbitmq-autocluster/releases/download/${RABBITMQ_AUTOCLUSTER_VERSION}/rabbitmq_aws-${RABBITMQ_AUTOCLUSTER_VERSION}.ez"
RUN rabbitmq-plugins enable --offline autocluster
