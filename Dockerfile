FROM alpine:edge

ENV BNBD_HOME=/bnbd


# Install ca-certificates
RUN apk add --no-cache --update ca-certificates supervisor wget

# UPDATE ME when new version is out !!!!
ARG CLI_LATEST_VERSION="0.8.0-hotfix"
ARG FULLNODE_LATEST_VERSION="0.8.0"
ARG GH_REPO_URL="https://github.com/binance-chain/node-binary/raw/master"
ARG FULLNODE_VERSION_PATH="fullnode/prod/${FULLNODE_LATEST_VERSION}"

# RUN set -ex \
# && cd /usr/local/bin/ \
# && wget -q https://github.com/binance-chain/node-binary/raw/master/cli/prod/$CLI_LATEST_VERSION/linux/bnbcli \
# && chmod 755 "./bnbcli" \
# && FULLNODE_BINARY_URL="$GH_REPO_URL/$FULLNODE_VERSION_PATH/linux/bnbchaind" \
# && wget  -q  "$FULLNODE_BINARY_URL" \
# && cp  ./bnbchaind  ./bnbchaind1 \
# && cp  ./bnbchaind  ./bnbchaind22 \
# && chmod 755 "./bnbchaind" \
# && chmod +x  "./bnbchaind" \
# && chmod 755 "./bnbchaind22" \
# && ls /usr/local/bin/

RUN mkdir -p /tmp/bin
WORKDIR /tmp/bin

RUN set -ex \
&& cd  /tmp/bin \
&& FULLNODE_BINARY_URL="$GH_REPO_URL/$FULLNODE_VERSION_PATH/linux/bnbchaind" \
&& wget  -q  "$FULLNODE_BINARY_URL"

RUN chmod +x /tmp/bin/bnbchaind

RUN install -m 0755 -o root -g root -t /usr/local/bin bnbchaind

#RUN install -m 0755 -o root -g root -t /usr/local/bin gaiad
#RUN install -m 0755 -o root -g root -t /usr/local/bin gaiacli


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
&& ls -l /usr/local/bin/ \
&& mkdir -p /tmp/bin  \
&& cd /tmp/bin \
&& cp  /usr/local/bin/bnbchaind  /tmp/bin/bnbchaind333 \
&& cp  /usr/local/bin/bnbchaind  /tmp/bin/bnbchaind4444 \
&& chmod 755 "./bnbchaind4444" \
&& ls -l /tmp/bin



#ENTRYPOINT ["/usr/local/bin/bnbchaind", "start"]
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]


STOPSIGNAL SIGINT
