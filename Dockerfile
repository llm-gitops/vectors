ARG PG_MAJOR=15
FROM postgres:$PG_MAJOR
ARG PG_MAJOR

COPY . /tmp/pgvector

RUN apt-get update && \
		apt-mark hold locales && \
		apt-get install -y --no-install-recommends build-essential postgresql-server-dev-$PG_MAJOR && \
		cd /tmp/pgvector && \
		make clean && \
		make OPTFLAGS="" && \
		make install && \
		mkdir /usr/share/doc/pgvector && \
		cp LICENSE README.md /usr/share/doc/pgvector && \
		rm -r /tmp/pgvector && \
		apt-get remove -y build-essential postgresql-server-dev-$PG_MAJOR && \
		apt-get autoremove -y && \
		apt-mark unhold locales && \
		rm -rf /var/lib/apt/lists/*

FROM ghcr.io/llm-gitops/postgres:15.4

ENV POSTGRES_USER     vectors
ENV POSTGRES_DB       vectors
ENV POSTGRES_PASSWORD vectors

COPY --from=0 /usr/share/postgresql/15/extension/vector*.sql /usr/share/postgresql/extension/
COPY --from=0 /usr/share/postgresql/15/extension/vector.control /usr/share/postgresql/extension/vector.control
COPY --from=0 /usr/lib/postgresql/15/lib/vector.so /usr/lib/postgresql/vector.so
COPY postgresql-entrypoint.sh /var/lib/postgres/initdb/postgresql-entrypoint.sh
