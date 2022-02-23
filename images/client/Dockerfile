# Phase 0: Builder
# ========================= 
FROM paritytech/ci-linux:production as builder

FROM docker.io/paritytech/ci-linux:production as builder

ARG BRANCH=data-discovery

# Install ssh client and git
RUN apt-get update && \
	apt-get install -y git openssh-client gettext-base sed && \
	rm -rf /var/lib/apt/lists 

# Download public key for github.com
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

# Clone private repository
RUN --mount=type=ssh \
	mkdir -p /src && \
	git clone -b ${BRANCH} git@github.com:maticnetwork/avail-light.git /src/avail-light && \
	cd /src/avail-light && \
	cargo b --release && \
	mkdir -p /avail-light && \
	mv target/release/avail-light /avail-light && \
	rm -rf /src

# Phase 1: Binary deploy 
# ========================= 
FROM debian:buster-slim

# Install ssh client and git
RUN apt-get update && \
	apt-get install -y libssl1.1 gettext-base wait-for-it ca-certificates && \
	rm -rf /var/lib/apt/lists 

COPY --from=builder /avail-light /avail-light
COPY ./resources/* /avail-light

ENV \
	HTTP_SERVER_HOST="127.0.0.1" \
	HTTP_SERVER_PORT=7000 \
	IPFS_SEED=1 \
	IPFS_PORT=37000 \
	IPFS_PATH="avail_ipfs_store" \
	FULL_NODE_RPC="http://host.docker.internal:9933" \
	FULL_NODE_WS="ws://host.docker.internal:9944" \
	APP_ID=0 \
	CONFIDENCE=92.0 \
	AVAIL_PATH="avail_path" \
	BOOTSTRAPS=[]

WORKDIR avail-light
VOLUME ["/tmp", "/avail/state"]
ENTRYPOINT ["/avail-light/start.sh"]
