FROM docker.elastic.co/beats/filebeat:6.1.0

COPY config /usr/share/filebeat/

USER root

RUN chown -R filebeat /usr/share/filebeat/*
RUN chmod -R go-w /usr/share/filebeat/*

USER filebeat

ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
CMD ["-e"]
