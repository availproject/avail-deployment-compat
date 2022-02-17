# Phase 0: Builder
# ========================= 
FROM node:14-bullseye as builder
   
RUN apt-get update && \
	apt-get install -y curl git gnupg && \
	rm -rf /var/lib/apt/lists 

# Download public key for github.com
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

ARG BRANCH=master
ARG NODE_ENV=production

RUN --mount=type=ssh \
	# Build DApp \
	git clone --branch ${BRANCH} https://github.com/maticnetwork/apps.git

RUN --mount=type=ssh \
	cd apps && \
	yarn && \
	yarn build:www && \
	mv packages/apps/build /html && \
	cd .. && \
	rm -rf apps

# Phase 1: Web Service deployment with static 
# ========================= 
FROM nginx:alpine
COPY --from=builder /html /usr/share/nginx/html
