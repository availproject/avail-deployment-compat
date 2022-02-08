FROM docker.io/paritytech/ci-linux:production as builder

ARG BRANCH=data-discovery

# Install ssh client and git
RUN apt-get update && \
	apt-get install -y git openssh-client && \
    apt-get install -y sed

# Download public key for github.com
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

# Clone private repository
RUN --mount=type=ssh git clone -b ${BRANCH} git@github.com:maticnetwork/avail-light.git

# RUN git clone --branch ${BRANCH} --depth 1 https://github.com/maticnetwork/avail-light.git  && \

RUN cd avail-light && \
    cargo build    
RUN cd avail-light && \
    echo "http_server_host = '127.0.0.1'\nhttp_server_port = 7000\nipfs_seed = 1\nipfs_port = 37000\nipfs_path = 'avail_ipfs_store'\nfull_node_rpc = 'http://host.docker.internal:9933'\nfull_node_ws = 'ws://host.docker.internal:9944'\napp_id = 0\nconfidence = 92.0\navail_path = 'avail_path'\nbootstraps = []\n" > config.yaml


VOLUME ["/tmp", "/avail/state"]    
# ENTRYPOINT ["/target/debug/avail-light"]