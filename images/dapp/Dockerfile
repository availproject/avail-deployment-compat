# Phase 0: Builder
# ========================= 
FROM ubuntu:18.04 as builder
   
RUN apt-get update && \
	apt-get install -y curl git gnupg && \
	curl -sL https://deb.nodesource.com/setup_10.x -o setup_10.x && \
	bash setup_10.x && \
	apt-get install -y nodejs && \
	rm -rf /var/lib/apt/lists 
 
ARG BRANCH=master
ARG NODE_ENV=production

RUN \ 
	# Build DApp \
	git clone --branch ${BRANCH} --depth 1 https://github.com/maticnetwork/apps.git && \
	cd apps && \
	npm install yarn -g && \
	yarn && \
	yarn build:www

RUN mv apps/packages/apps/build /html && \
	rm -rf apps

# Phase 1: Web Service deployment with static 
# ========================= 
FROM nginx:alpine
COPY --from=builder /html /usr/share/nginx/html
