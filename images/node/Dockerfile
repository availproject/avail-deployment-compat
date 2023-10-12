# Phase 0: Builder
# ========================= 
FROM paritytech/ci-linux:production as builder
   
RUN apt-get update && \
	apt-get install -y git openssh-client && \
	rm -rf /var/lib/apt/lists 
 
ARG PROFILE=release
ARG BRANCH=master

RUN \ 
	# Build DA \
	git clone --branch ${BRANCH} --depth 1 https://github.com/maticnetwork/substrate.git

RUN \
	cd substrate && \
	echo "Using profile ${PROFILE}" && \
	if test ${PROFILE} = 'release'; then \ 
		cargo build --release -p node-template; \
	else \
		cargo build -p node-template; \
	fi && \
	# Install binaries \ 
	mkdir -p /da/bin && \
	mv target/${PROFILE}/node-template /da/bin && \
	# and clean \
	cd .. && \
	rm -rf substrate


# Phase 1: Binary deploy 
# ========================= 
FROM debian:buster-slim

ARG PROFILE=release

COPY --from=builder /da/ /da
RUN  \
	echo "Using profile $PROFILE" && \
	if test ${PROFILE} = 'debug'; then \
		echo "Install debug" && \
		apt-get update && \
		apt-get install -y screen lldb && \
		rm -rf /var/lib/apt/lists ; \
	else \
		echo "Install release" ; \
	fi

VOLUME ["/tmp", "/da/state", "/da/keystore"]
ENTRYPOINT ["/da/bin/node-template"]
