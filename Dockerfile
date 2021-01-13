FROM alpine:edge

ENV BNBD_HOME=/bnbd


# Install ca-certificates
RUN apk add --no-cache --update ca-certificates supervisor wget lz4

# UPDATE ME when new version is out !!!!
ARG CLI_LATEST_VERSION="0.8.0-hotfix"
ARG FULLNODE_LATEST_VERSION="0.8.0"
ARG GH_REPO_URL="https://github.com/binance-chain/node-binary/raw/master"
ARG FULLNODE_VERSION_PATH="fullnode/prod/${FULLNODE_LATEST_VERSION}"

RUN set -ex \
&& cd /usr/local/bin/ \
&& wget -q https://github.com/binance-chain/node-binary/raw/master/cli/prod/$CLI_LATEST_VERSION/linux/bnbcli \
&& chmod 755 "./bnbcli" \
&& FULLNODE_BINARY_URL="$GH_REPO_URL/$FULLNODE_VERSION_PATH/linux/bnbchaind" \
&& wget  -q  "$FULLNODE_BINARY_URL" \
&& chmod 755 "./bnbchaind" \
&& ls /usr/local/bin/


RUN set -ex \
&& mkdir -p /tmp/config  \
&& cd /tmp/config \
&& FULLNODE_CONFIG_URL="$GH_REPO_URL/$FULLNODE_VERSION_PATH/config"  \
&& wget  -q   "$FULLNODE_CONFIG_URL/app.toml"  \
&& wget  -q   "$FULLNODE_CONFIG_URL/config.toml"  \
&& wget  -q   "$FULLNODE_CONFIG_URL/genesis.json"  \
&& sed   -i   's/logToConsole = false/logToConsole = true/g'   app.toml


# Add supervisor configuration files
RUN mkdir -p /etc/supervisor/conf.d/
COPY /supervisor/supervisord.conf /etc/supervisor/supervisord.conf
COPY /supervisor/conf.d/* /etc/supervisor/conf.d/


WORKDIR $BNBD_HOME


# Expose ports for bnbd
EXPOSE 27146 27147 26660

# Add entrypoint script
COPY ./scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod u+x /usr/local/bin/entrypoint.sh

RUN set -ex \
&& ls /usr/local/bin/

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]


STOPSIGNAL SIGINT
