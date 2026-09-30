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

Initial observed labels included:

```text
container
job
service
service_name
```

This confirmed that Promtail was successfully forwarding log streams to Loki.

After the updated NGINX image was deployed through Nomad, Loki reported the NGINX allocation container:

```text
nginx-576157b3-334f-446f-fb31-81725cee0acb
```

The associated stream labels included:

```text
container      = nginx-576157b3-334f-446f-fb31-81725cee0acb
detected_level = unknown
job            = nginx-nomad
nomad_alloc_id = 576157b3-334f-446f-fb31-81725cee0acb
service        = nginx-app
service_name   = nginx-app
```

## LogQL Verification

The deployed Nomad allocation used the immutable CI image:

```text
ghcr.io/abihail22558/devops-intern-final:44883a472842de973a8b23d9957a8955d83a57a5
```

The allocation was healthy and exposed NGINX on dynamic port `21903`.

A request to a missing path was first tested with GET:

```bash
curl -s -o /dev/null -w "GET /missing-page -> HTTP %{http_code}\n" \
  http://127.0.0.1:21903/missing-page
```

Observed result:

```text
GET /missing-page -> HTTP 200
```

The `200` response is expected because the NGINX configuration uses SPA fallback:

```nginx
try_files $uri $uri/ /index.html;
```

To generate a non-200 NGINX access-log event without changing the application configuration, a POST request was used:

```bash
curl -s -o /dev/null \
  -w "POST /missing-page -> HTTP %{http_code}\n" \
  -X POST \
  http://127.0.0.1:21903/missing-page
```

Observed result:

```text
POST /missing-page -> HTTP 405
```

The NGINX Docker logs confirmed that the request was written to stdout:

```text
172.17.0.1 - - [28/Sep/2026:13:06:20 +0000] "POST /missing-page HTTP/1.1" 405 157 "-" "curl/8.18.0"
```

Loki was then queried with LogQL to isolate the NGINX 405 request:

```logql
{service="nginx-app", container="nginx-576157b3-334f-446f-fb31-81725cee0acb"} |~ " 405 "
```

The query returned exactly one matching log entry:

```text
POST /missing-page HTTP/1.1" 405 157
```

This confirmed that the NGINX access log travelled successfully through:

```text
NGINX → Docker stdout → Promtail → Loki
```

## Grafana Verification

Grafana 12.1.1 was accessed through:

```text
http://localhost:3000
```

Loki was configured as a Grafana data source using the Docker Compose service URL:

```text
http://loki:3100
```

The data source connection test completed successfully.

In Grafana Explore, the Loki data source was used to query:

```logql
{service="nginx-app", container="nginx-576157b3-334f-446f-fb31-81725cee0acb"} |~ " 405 "
```

Grafana displayed the expected NGINX access log:

```text
2026-09-28 14:06:20
172.17.0.1 - - [28/Sep/2026:13:06:20 +0000] "POST /missing-page HTTP/1.1" 405 157 "-" "curl/8.18.0"
```

The Grafana Explore evidence is captured in:

```text
docs/screenshots/task6-grafana-explore.png
```

This completes the end-to-end log aggregation verification for Task 6.

## Troubleshooting

### NGINX logs were not appearing in Loki

**Problem:** Loki initially received Promtail streams from the monitoring containers, but no NGINX allocation logs were present.

**Cause:** The running Nomad allocation was using the pre-Task-6 image, whose NGINX access and error logs were written to `/tmp` instead of stdout/stderr.

**Resolution:** Updated `app/nginx.conf` to send NGINX access logs to `/dev/stdout` and errors to `/dev/stderr`. The updated image was published through CI and the Nomad job was redeployed using the immutable image tag:

```text
44883a472842de973a8b23d9957a8955d83a57a5
```

### GET request returned HTTP 200 instead of 404

**Problem:** A GET request to `/missing-page` returned HTTP 200 rather than the expected non-200 response.

**Cause:** The NGINX configuration intentionally uses SPA fallback:

```nginx
try_files $uri $uri/ /index.html;
```

Therefore, the missing path falls back to `index.html`.

**Resolution:** A POST request was used against the same missing path. NGINX correctly returned HTTP 405, producing a non-200 access-log event that could be isolated in Loki.

### Loki instant query returned an error

**Problem:** An initial request to `/loki/api/v1/query` returned:

```text
log queries are not supported as an instant query type,
please change your query to a range query type
```

**Resolution:** Changed the query endpoint to `/loki/api/v1/query_range`, which successfully returned Loki log streams.

## Final Verification

Task 6 verification confirmed:

1. Loki, Promtail, and Grafana were running through Docker Compose.
2. Promtail successfully discovered the Nomad NGINX allocation.
3. NGINX access logs were written to Docker stdout.
4. Loki received the NGINX logs with meaningful labels including `job`, `container`, `service`, and `nomad_alloc_id`.
5. A LogQL query successfully isolated the HTTP 405 NGINX request.
6. Loki was successfully connected to Grafana.
7. Grafana Explore displayed the expected NGINX log entry.
8. The required Grafana Explore screenshot was captured in `docs/screenshots/task6-grafana-explore.png`.
