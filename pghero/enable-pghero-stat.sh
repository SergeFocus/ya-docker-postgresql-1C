#!/bin/bash

PG_CONF=${PG_DATADIR}/postgresql.conf

docker exec -it yadockerpostgresql1c_PostgreSQL_1 \
    psql -U postgres -d powa -c '
        CREATE TABLE "pghero_query_stats" (
            "id" serial primary key,
            "database" text,
            "user" text,
            "query" text,
            "query_hash" bigint,
            "total_time" float,
            "calls" bigint,
            "captured_at" timestamp
            );
        CREATE INDEX ON "pghero_query_stats" (
            "database",
            "captured_at"
            );
        CREATE TABLE "pghero_space_stats" (
            "id" serial primary key,
            "database" text,
            "schema" text,
            "relation" text,
            "size" bigint,
            "captured_at" timestamp
            );
        CREATE INDEX ON "pghero_space_stats" (
            "database",
            "captured_at"
            );'

docker run --rm \
    -e DATABASE_URL=postgres://postgres:somepass@192.168.99.100:5432/powa \
    ankane/pghero \
    bin/rake pghero:capture_query_stats

docker run --rm \
    -e DATABASE_URL=postgres://postgres:somepass@192.168.99.100:5432/powa \
    ankane/pghero \
    bin/rake pghero:capture_space_stats
