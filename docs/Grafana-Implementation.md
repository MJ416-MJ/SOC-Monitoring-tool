# Grafana Implementation -- SOC Monitoring Project

## 1. Overview

Grafana provides the visualization layer for the SOC Monitoring
environment. It brings together metrics collected by Prometheus and
problem information retrieved from Zabbix in a single dashboard.

**Dashboard title:** Host Availability\
**Grafana address:** `http://10.10.10.11:3000`\
**Dashboard export:** `grafana/Host Availability-1795027763607.json`

The dashboard currently contains five panels.

## 2. Data sources

### Prometheus

-   **Grafana data source type:** Prometheus
-   **URL configured in Grafana:** `http://prometheus:9090`
-   **Purpose:** Supplies host availability, CPU usage, filesystem
    metrics and Prometheus alert-state metrics.

### Zabbix

-   **Grafana data source type:** Zabbix
-   **API endpoint configured in Grafana:**
    `http://zabbix-web-1:8080/api_jsonrpc.php`
-   **Purpose:** Supplies Zabbix problem information for the dashboard.
-   **Network note:** The Grafana container was connected to the
    `zabbix_default` Docker network so it could reach the Zabbix web/API
    service by its container name.

Datasource credentials are configured in Grafana and are not included in
this document or the dashboard export.

## 3. Dashboard panels

### 3.1 Host Availability

**Visualization:** Stat\
**Data source:** Prometheus\
**PromQL:**

``` promql
up{job="node"}
```

This query reports whether each monitored Node Exporter target is
reachable by Prometheus. A value of `1` means the target is up; `0`
means it is down.

**Validation observed:** Both `10.10.10.21:9100` and `10.10.10.22:9100`
displayed `1`.

### 3.2 CPU Usage (%)

**Visualization:** Time series\
**Data source:** Prometheus\
**PromQL:**

``` promql
100 - (avg by (instance) (
  rate(node_cpu_seconds_total{mode="idle"}[5m])
) * 100)
```

This calculates CPU utilization as 100 percent minus the average idle
CPU percentage over a five-minute rate window, grouped by monitored
instance.

**Validation observed:** Time-series data was displayed for both
monitored targets.

### 3.3 Disk Free Space (%)

**Visualization:** Time series\
**Data source:** Prometheus\
**PromQL:**

``` promql
(
  node_filesystem_avail_bytes{mountpoint="/", fstype!~"tmpfs|overlay"}
  /
  node_filesystem_size_bytes{mountpoint="/", fstype!~"tmpfs|overlay"}
) * 100
```

This calculates the percentage of available space on the root
filesystem. The filters exclude temporary filesystems and overlay
filesystems.

**Validation observed:** Both monitored targets displayed filesystem
data.

### 3.4 Active Alerts

**Visualization:** Table\
**Data source:** Prometheus\
**PromQL:**

``` promql
ALERTS{alertstate="firing"}
```

The query returns Prometheus alert series whose state is `firing`. The
panel uses the **Labels to fields** transformation to display alert
labels in table columns.

**Validation observed:** One alert series was visible in the dashboard
screenshot. Its full details should be inspected in Grafana/Prometheus
when reviewing the alert.

### 3.5 Zabbix Network Problems

**Visualization:** Table\
**Data source:** Zabbix\
**Query type:** Problems\
**Group:** All\
**Host:** All\
**Minimum severity:** All severities\
**Problem display:** All problems

This panel is intended to display current Zabbix problems for the
selected scope.

**Validation observed:** The panel displayed "No rows" at the time of
the dashboard screenshot. This means no problem rows were returned by
the current query at that moment; it should not by itself be treated as
proof that the Zabbix integration is unavailable.

## 4. Monitored systems

The Prometheus panels currently show these Node Exporter targets:

  Host address      Exporter port   Availability shown
  --------------- --------------- --------------------
  `10.10.10.21`            `9100`             UP (`1`)
  `10.10.10.22`            `9100`             UP (`1`)

## 5. Validation summary

The dashboard was opened and visually checked after configuring both
data sources.

  Component                 Observed result
  ------------------------- ------------------------------------
  Prometheus data source    Configured and tested successfully
  Zabbix data source        Configured and tested successfully
  Host Availability         Both targets UP
  CPU Usage                 Time-series data visible
  Disk Free Space           Time-series data visible
  Active Alerts             One alert series visible
  Zabbix Network Problems   No rows at time of validation

## 6. Importing the dashboard

To import the dashboard into another Grafana installation:

1.  Ensure the Prometheus data source is configured and can query the
    Prometheus server.
2.  Install/configure the Grafana Zabbix data source plugin if the
    Zabbix panel is required.
3.  Configure the Zabbix API endpoint and credentials in Grafana.
4.  Open **Dashboards** and choose **New → Import** (the exact menu
    wording may vary by Grafana version).
5.  Upload `Host Availability-1795027763607.json`.
6.  During import, map the dashboard's Prometheus and Zabbix data
    sources to the corresponding data sources in the destination Grafana
    instance.
7.  Open the dashboard and confirm that all five panels return the
    expected data.

The exported dashboard contains references to the datasource UIDs from
the original Grafana instance. When importing elsewhere, select the
matching destination data sources rather than assuming those UIDs will
exist.

## 7. Maintenance notes

-   Keep datasource credentials out of Git.
-   If a data source is renamed or recreated, verify the dashboard's
    datasource mapping.
-   Check that both Node Exporter targets remain reachable when
    availability panels show `0` or no data.
-   Investigate firing alerts in Prometheus/Alertmanager rather than
    assuming every alert represents a host outage.
-   Review the Zabbix problem query if the panel remains empty when
    Zabbix shows active problems.

## 8. Repository location

Store this documentation file at:

`docs/Grafana-Implementation.md`

Store the dashboard JSON export at:

`grafana/Host Availability-1795027763607.json`
