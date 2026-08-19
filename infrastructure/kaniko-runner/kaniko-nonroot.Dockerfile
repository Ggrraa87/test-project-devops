
ARG KANIKO_IMAGE=gcr.io/kaniko-project/executor:v1.23.2-debug@sha256:c3109d5926a997b100c4343944e06c6b30a6804b2f9abe0994d3de6ef92b028e
ARG FETCH_IMAGE=golang:1.25.13-bookworm@sha256:e401dae1bf814e29204a8cb7915682e1780951e609ca0dd8865ee1937f510c48


FROM ${FETCH_IMAGE} AS fetch


ARG JQ_VERSION=1.7.1
ARG JQ_SHA256=5942c9b0934e510ee61eb3e30273f1b3fe2590df93933a93d7c58b81d19c8ff5

RUN curl -fsSLo /jq \
      "https://github.com/jqlang/jq/releases/download/jq-${JQ_VERSION}/jq-linux-amd64" \
    && echo "${JQ_SHA256}  /jq" | sha256sum -c - \
    && chmod 0755 /jq \
    && /jq --version \
    && ldd /jq 2>&1 | grep -q "not a dynamic executable"


FROM ${KANIKO_IMAGE}

LABEL org.opencontainers.image.title="kaniko-nonroot" \
      org.opencontainers.image.description="Kaniko executor running as UID 65532, with jq so the pipeline's Vault helpers work here too" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.base.name="gcr.io/kaniko-project/executor:v1.23.2-debug"

USER 0:0


RUN mkdir -p /workspace/.docker /workspace/output /tmp/kaniko \
    && chown -R 65532:65532 /workspace /tmp/kaniko \
    && chmod 0750 /workspace /workspace/.docker /workspace/output /tmp/kaniko

COPY --from=fetch --chown=root:root --chmod=0755 /jq /usr/local/bin/jq

RUN jq --version

ENV HOME=/workspace \
    DOCKER_CONFIG=/workspace/.docker \
    TMPDIR=/tmp/kaniko

USER 65532:65532
WORKDIR /workspace

ENTRYPOINT ["/kaniko/executor"]
