FROM library/rethinkdb:2.0.3

MAINTAINER Rajiv Bose <rajiv@lesbose.com>

RUN apt-get update && \
 apt-get install -y curl jq && \
 apt-get clean && \
 rm -rf /var/lib/apt/lists/*

ADD ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["rethinkdb", "--bind", "all"]
