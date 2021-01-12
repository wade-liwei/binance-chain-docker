FROM alpine:edge

ENV BNBD_HOME=/bnbd

# ENV FULLNODE_LATEST_VERSION="0.8.0"
# ENV GH_REPO_URL="https://github.com/binance-chain/node-binary/raw/master"
# ENV FULLNODE_VERSION_PATH="fullnode/prod/${FULLNODE_LATEST_VERSION}"
# ENV FULLNODE_CONFIG_URL="$GH_REPO_URL/${FULLNODE_VERSION_PATH}/config"

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
&& wget -q "$FULLNODE_BINARY_URL" \
&& chmod 755 "./bnbchaind"


RUN set -ex \
&& mkdir -p /tmp/config  \
&& cd /tmp/config \
&& FULLNODE_CONFIG_URL="$GH_REPO_URL/$FULLNODE_VERSION_PATH/config" \
&& wget -q "$FULLNODE_CONFIG_URL/app.toml" \
&& wget -q "$FULLNODE_CONFIG_URL/config.toml" \
&& wget -q "$FULLNODE_CONFIG_URL/genesis.json" \
&& sed -i 's/logToConsole = false/logToConsole = true/g' app.toml


COPY --from=buildenv /go/bin/gaiad /tmp/bin
COPY --from=buildenv /go/bin/gaiacli /tmp/bin
RUN install -m 0755 -o root -g root -t /usr/local/bin gaiad
RUN install -m 0755 -o root -g root -t /usr/local/bin gaiacli



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
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]


STOPSIGNAL SIGINT
