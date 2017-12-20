# https://github.com/elastic/logstash-docker
FROM docker.elastic.co/logstash/logstash-oss:6.1.0

USER root

RUN mkdir /var/log/pg-logs/

RUN chown -R logstash:logstash /var/log/pg-logs/

USER logstash

EXPOSE 9600 5044 5000

ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]


# Add your logstash plugins setup here
# Example: RUN logstash-plugin install logstash-filter-json


