# Phase 0: Builder
# ========================= 
FROM paritytech/ci-linux:production as builder
   
RUN apt-get update && \
	apt-get install -y git openssh-client && \
	rm -rf /var/lib/apt/lists 
 
ARG BRANCH=master

# Download public key for github.com
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

RUN --mount=type=ssh \
	# Build DA \
	git clone --branch ${BRANCH} git@github.com:maticnetwork/avail.git && \
	cd avail && \
	cargo build --release && \
	# Install binaries \ 
	mkdir -p /da/bin && \
	mv target/release/data-avail /da/bin && \
	# and clean \
	cd .. && \
	rm -rf avail


# Phase 1: Binary deploy 
# ========================= 
FROM debian:buster-slim

COPY --from=builder /da/ /da
WORKDIR /da

VOLUME ["/tmp", "/da/state", "/da/keystore"]
ENTRYPOINT ["/da/bin/data-avail"]
