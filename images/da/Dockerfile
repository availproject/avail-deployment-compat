# Phase 0: Builder
# ========================= 
FROM paritytech/ci-linux:production as builder
   
RUN apt-get update && \
	apt-get install -y git openssh-client && \
	rm -rf /var/lib/apt/lists 
 
ARG BRANCH=main

RUN \
	mkdir -p /da/bin && \
	mkdir -p /da/genesis && \
	# Build DA \
	git clone --branch ${BRANCH} https://github.com/maticnetwork/avail.git && \
	cp -r avail/misc/genesis /da && \
	cd avail && \
	cargo build --release -p data-avail && \
	# Install binaries \ 
	mv target/release/data-avail /da/bin && \
	# and clean \
	cd .. && \
	rm -rf avail


# Phase 1: Binary deploy 
# ========================= 
FROM debian:buster-slim

RUN apt-get update && \
	apt-get install -y curl && \
	rm -rf /var/lib/apt/lists 
 
COPY --from=builder /da/ /da
WORKDIR /da

VOLUME ["/tmp", "/da/state", "/da/keystore"]
ENTRYPOINT ["/da/bin/data-avail"]
