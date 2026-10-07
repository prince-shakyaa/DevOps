# Observability: Metrics, Logs and Traces

## Monitoring vs observability

**Monitoring** answers questions you thought of in advance: is the API up, is CPU above
80%, are 5xx responses above 5%? It is dashboards and alerts built for failure modes you
already know about.

**Observability** is a property of the system: how well you can work out its internal state
from what it emits, including for failures **nobody predicted**. A system is observable when
you can ask a new question ("why are only requests from hostel B slow, and only since the
2 pm deploy?") and answer it from the telemetry that already exists, without shipping new
code.

| | Monitoring | Observability |
|---|---|---|
| Question | "Is it broken?" | "Why is it broken, and where?" |
| Failures covered | known unknowns | unknown unknowns |
| Typical output | dashboard, alert | ad-hoc queries over high-cardinality data |
| Relationship | a subset of observability | built on the same metrics, plus logs and traces |

### Why it is needed

- **Distributed systems fail partially.** A request may cross an Ingress, three services and a
  database. "The app is slow" could be any of them.
- **Kubernetes is dynamic.** Pods are rescheduled, scaled and replaced, so IP addresses and
  even Pod names are short-lived. You cannot SSH into "the server" because there isn't one.
- **MTTR.** Time to recover is mostly time to *find* the problem. Good telemetry cuts that
  time.
- **Capacity and cost.** Real usage, compared with what was requested, drives right-sizing
  (see `grade-crunch` at 574% of its CPU request in the main README).
- **SLOs.** You cannot promise 99.9% availability without measuring it.

## The three pillars

### Metrics: numbers over time

A metric is a numeric sample with a name and labels, taken at regular intervals:
`http_requests_total{namespace="campus-obs",status="500"} 1832`.

- Cheap to store and fast to aggregate, which makes them the basis for alerts and dashboards.
- Types: **counter** (only goes up, used with `rate()`), **gauge** (up and down, such as
  memory), **histogram/summary** (distributions such as latency percentiles).
- Limit: they tell you *that* the 5xx rate went up, not which request failed or why.
- In this repo: Prometheus, `kubectl top`, the Grafana dashboards.

### Logs: discrete events with context

Timestamped records written by the code: `level=error msg="connection refused:
fees-db:5432"`.

- Very detailed: error messages, stack traces, IDs.
- Structured (JSON or key=value) logs can be filtered and parsed, while free text can only be
  grepped.
- Limit: high volume and cost, and on their own they lose the connection between services.
- In this repo: `kubectl logs`, Loki via Alloy, Grafana Explore.

### Traces: the path of one request

A trace follows one request across services. Each hop is a **span** with a start time and a
duration, and all spans share one trace ID that is passed along in headers (W3C
`traceparent`).

- Shows *where* the time went: 20 ms in the API, 900 ms waiting on the database.
- Needs instrumentation in the code, usually OpenTelemetry SDKs, and a backend such as Jaeger,
  Tempo or Zipkin.
- Not deployed in this lab. podinfo supports OpenTelemetry, and Tempo would be the natural
  next piece next to Loki.

### How the three work together

1. An **alert** fires on a metric: 5xx ratio > 5%.
2. The **dashboard** narrows it down: only `campus-api`, starting 14:25.
3. **Logs** for that app and time window show the actual errors.
4. A **trace** of one failing request shows which downstream call failed. With exemplars, a
   metric data point links straight to a trace ID, and that trace ID appears in the logs.

## Common tools

| Area | Tools |
|---|---|
| Metrics | Prometheus, Thanos / Mimir / VictoriaMetrics (long-term), Datadog, CloudWatch |
| Logs | Loki, Elasticsearch / OpenSearch (ELK/EFK), Splunk, CloudWatch Logs |
| Log shipping | Grafana Alloy, Fluent Bit, Fluentd, Vector, Promtail (retired) |
| Traces | Jaeger, Grafana Tempo, Zipkin, AWS X-Ray |
| Instrumentation standard | OpenTelemetry (SDKs + Collector) for all three pillars |
| Visualisation | Grafana, Kibana, vendor UIs |
| Alerting | Alertmanager, Grafana Alerting, PagerDuty / Opsgenie for on-call |

## Kubernetes observability

What there is to watch, and where it comes from:

| Layer | Signal | Source |
|---|---|---|
| Node | CPU, memory, disk, network | node-exporter |
| Container | CPU, memory, throttling, OOM | kubelet/cAdvisor (`container_*`) |
| Objects | desired vs ready replicas, restarts, Pod phase | kube-state-metrics (`kube_*`) |
| Control plane | API latency, etcd, scheduler | component `/metrics` endpoints |
| Application | RED: Rate, Errors, Duration | app `/metrics` via ServiceMonitor |
| Logs | stdout/stderr of every container | node log files → Alloy/Fluent Bit → Loki |
| Events | scheduling, probe failures, back-offs | Kubernetes Events API (kept ~1h) |
| Health | liveness, readiness, startup | probes, `kube_pod_status_ready` |

Kubernetes-specific practices:

- **Log to stdout/stderr.** The runtime collects it, so the app does not manage log files.
- **Label everything.** Namespace, Pod, app and version labels are what make queries useful.
- **Discover targets automatically** (ServiceMonitors, Pod discovery). Pod IPs change too
  often for anything static.
- **Keep telemetry outside the failing thing.** Logs held only inside a crashed Pod are gone
  with it, which is why `fee-sync`'s earlier attempts are in Loki but not in `kubectl logs`.
- **Watch requests and limits**, because the scheduler and the HPA both work from them.

---

**Prince Shakya** · Roll No. 24BCS10084
