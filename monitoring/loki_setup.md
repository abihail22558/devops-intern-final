# Grafana Loki Log Aggregation Setup

## Stack Components

The Task 6 observability stack consists of:

* Grafana Loki 3.7.0 — log aggregation and querying
* Grafana Promtail 3.6.11 — log collection and forwarding
* Grafana 12.1.1 — log visualization and Explore queries

The stack is defined in `monitoring/docker-compose.yaml`.

## Stack Startup

The monitoring stack was started with:

```bash
docker compose -f monitoring/docker-compose.yaml up -d
```

Running containers were verified with:

```bash
docker compose -f monitoring/docker-compose.yaml ps
```

The following services were running:

* `monitoring-loki-1`
* `monitoring-promtail-1`
* `monitoring-grafana-1`

## Promtail Configuration

Promtail uses Docker service discovery through the Docker socket and filters for Nomad allocation containers.

The configuration assigns the following meaningful labels:

* `job=nginx-nomad`
* `container=<container-name>`
* `service=nginx-app`
* `nomad_alloc_id=<Nomad allocation ID>`

Promtail configuration syntax was validated successfully:

```text
Valid config file! No syntax issues found
```

## Loki Label Verification

Loki was queried for available labels:

```bash
docker run --rm \
  --network monitoring_default \
  curlimages/curl:8.18.0 \
  http://monitoring-loki-1:3100/loki/api/v1/labels
```

Observed labels included:

```text
container
job
service
service_name
```

This confirmed that Promtail was successfully forwarding log streams to Loki.

## LogQL Verification

A Loki range query was used to verify log ingestion:

```logql
{job="nginx-nomad"}
```

The query returned log streams from the monitoring stack.

Further investigation showed that the expected NGINX allocation container was not yet present in Loki's container label values.

## Troubleshooting

### NGINX logs were not appearing in Loki

**Problem:** Loki initially received Promtail streams from the monitoring containers, but no NGINX allocation logs were present.

**Cause:** The running Nomad allocation was using the pre-Task-6 image, whose NGINX access/error logs were written to `/tmp` instead of stdout/stderr.

**Resolution:** Updated `app/nginx.conf` to send NGINX access logs to `/dev/stdout` and errors to `/dev/stderr`; the updated image will be published through CI and redeployed through Nomad.

### Loki instant query returned an error

**Problem:** An initial request to `/loki/api/v1/query` returned:

```text
log queries are not supported as an instant query type,
please change your query to a range query type
```

**Resolution:** Changed the query endpoint to `/loki/api/v1/query_range`, which successfully returned Loki log streams.

## Next Verification Steps

After the updated NGINX image is published through CI and redeployed through Nomad:

1. Generate a deliberate 404 request against the Nomad NGINX service.
2. Confirm the NGINX access log appears in Loki.
3. Run a LogQL query isolating the non-200 request.
4. Configure Loki as a Grafana data source.
5. Verify the query in Grafana Explore.
6. Capture the required Grafana Explore screenshot in `docs/screenshots/`.
