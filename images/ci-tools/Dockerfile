FROM golang:1.25.13-bookworm@sha256:e401dae1bf814e29204a8cb7915682e1780951e609ca0dd8865ee1937f510c48

ARG GOSEC_VERSION=v2.28.0
ARG GITLEAKS_VERSION=8.30.1
ARG GOVULNCHECK_VERSION=v1.1.4
ARG TRIVY_VERSION=0.74.0
ARG SYFT_VERSION=1.51.0

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates curl git jq openssl python3 gcc libc6-dev tar gzip \
    && rm -rf /var/lib/apt/lists/*

RUN GOBIN=/usr/local/bin go install github.com/securego/gosec/v2/cmd/gosec@${GOSEC_VERSION} \
    && GOBIN=/usr/local/bin go install golang.org/x/vuln/cmd/govulncheck@${GOVULNCHECK_VERSION}

RUN curl -fsSLo /tmp/gitleaks.tar.gz \
      "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" \
    && tar -xzf /tmp/gitleaks.tar.gz -C /usr/local/bin gitleaks \
    && curl -fsSLo /tmp/trivy.tar.gz \
      "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" \
    && tar -xzf /tmp/trivy.tar.gz -C /usr/local/bin trivy \
    && curl -fsSLo /tmp/syft.tar.gz \
      "https://github.com/anchore/syft/releases/download/v${SYFT_VERSION}/syft_${SYFT_VERSION}_linux_amd64.tar.gz" \
    && tar -xzf /tmp/syft.tar.gz -C /usr/local/bin syft \
    && chmod 0755 /usr/local/bin/gitleaks /usr/local/bin/trivy /usr/local/bin/syft \
    && rm -f /tmp/*.tar.gz

RUN groupadd --gid 65532 nonroot \
    && useradd --uid 65532 --gid 65532 --home-dir /workspace --create-home --shell /usr/sbin/nologin nonroot \
    && mkdir -p /workspace/.cache/go-build /workspace/.cache/go-mod /workspace/.cache/trivy \
    && chown -R 65532:65532 /workspace

ENV HOME=/workspace \
    GOCACHE=/workspace/.cache/go-build \
    GOMODCACHE=/workspace/.cache/go-mod \
    TRIVY_CACHE_DIR=/workspace/.cache/trivy

USER 65532:65532
WORKDIR /workspace
