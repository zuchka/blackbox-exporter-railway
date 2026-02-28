# Prometheus Blackbox Exporter — Railway Template

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/Y0tr7x?referralCode=9kQOPq&utm_medium=integration&utm_source=template&utm_campaign=generic)

The [Prometheus Blackbox Exporter](https://github.com/prometheus/blackbox_exporter) probes HTTP, TCP, DNS, and ICMP endpoints and exposes the results as Prometheus metrics. Use it to monitor external service availability from your Prometheus instance.

## Usage

Once deployed, probe an endpoint by sending a GET request:

```
GET /probe?target=https://example.com&module=http_2xx
```

The response contains Prometheus metrics including:

```
probe_success 1
probe_duration_seconds 0.123
probe_http_status_code 200
```

### Available modules

| Module | Description |
|---|---|
| `http_2xx` | HTTP GET, expect 2xx response |
| `http_post_2xx` | HTTP POST, expect 2xx response |
| `tcp_connect` | Basic TCP connectivity check |
| `ssh_banner` | TCP, expect SSH-2.0- banner |
| `dns_query` | DNS A record resolution |

See [CONFIGURATION.md](https://github.com/prometheus/blackbox_exporter/blob/master/CONFIGURATION.md) for full module configuration options. Mount a custom `blackbox.yml` to define additional modules.

## Prometheus scrape config

Add the following to your `prometheus.yml` to scrape probes via this service. Replace `<your-railway-domain>` with your deployed service URL.

```yaml
scrape_configs:
  - job_name: blackbox
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
          - https://example.com
          - https://your-api.com/health
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: <your-railway-domain>:443
```

## Details

- **Version:** [v0.28.0](https://github.com/prometheus/blackbox_exporter/releases/tag/v0.28.0)
- **Metrics endpoint:** `/metrics`
- **Default port:** `9115` (Railway overrides via `$PORT`)
- **Image:** alpine:3.21 (~25 MB)
