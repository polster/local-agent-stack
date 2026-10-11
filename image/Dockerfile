# Framework overlay that installs opencode + optional BMAD / Superpowers.
#
# Pin BASE by digest. Get the current base from:
#   openshell sandbox list -o json
ARG BASE=TODO-openshell-base-image@sha256:TODO
FROM ${BASE}

ARG OPENCODE_VERSION=1.18.34
ARG BMAD=0
ARG SUPERPOWERS=0

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl nodejs npm \
 && rm -rf /var/lib/apt/lists/* \
 && npm install -g "opencode-ai@${OPENCODE_VERSION}" \
 && opencode --version

COPY image/opencode.json /etc/opencode/opencode.json
ENV OPENCODE_CONFIG=/etc/opencode/opencode.json

COPY frameworks /opt/frameworks
RUN if [ "$BMAD" = "1" ]; then /opt/frameworks/bmad/install.sh; fi \
 && if [ "$SUPERPOWERS" = "1" ]; then /opt/frameworks/superpowers/install.sh; fi

WORKDIR /workspace
