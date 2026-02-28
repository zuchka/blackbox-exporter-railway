# Stage 1: fetch pre-compiled binary from GitHub releases
FROM alpine:3.21 AS builder

ARG VERSION=0.28.0
ARG TARGETARCH

RUN apk add --no-cache curl tar

RUN curl -fsSL \
    "https://github.com/prometheus/blackbox_exporter/releases/download/v${VERSION}/blackbox_exporter-${VERSION}.linux-${TARGETARCH}.tar.gz" \
    | tar -xz --strip-components=1 -C /tmp \
      "blackbox_exporter-${VERSION}.linux-${TARGETARCH}/blackbox_exporter" \
 && mv /tmp/blackbox_exporter /bin/blackbox_exporter \
 && chmod +x /bin/blackbox_exporter

# Stage 2: minimal runtime image
FROM alpine:3.21

RUN apk add --no-cache ca-certificates

COPY --from=builder /bin/blackbox_exporter /bin/blackbox_exporter
COPY blackbox.yml /etc/blackbox_exporter/config.yml

USER nobody

EXPOSE 9115

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["/bin/blackbox_exporter --config.file=/etc/blackbox_exporter/config.yml --web.listen-address=:${PORT:-9115}"]
