FROM python:3

RUN pip install mamonsu

ENV ZABBIX_URL=http://127.0.0.1:8081/ \
    ZABBIX_USER=Admin \
    ZABBIX_PASSWD=zabbix \
    ZABBIX_SERVER=127.0.0.1 \
    PG_SERVER=127.0.0.1 \
    PG_USER=postgres \
    MAMONSU_DB=mamonsu

ADD agent.conf /etc/mamonsu/

COPY mamonsu-entrypoint.sh /

COPY init-start.sh /

ENTRYPOINT ["/bin/bash"]
CMD ["/mamonsu-entrypoint.sh"]

EXPOSE 10050
