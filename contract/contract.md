# 3. The Shared Contract (Everyone Follows This)

## Infrastructure Overview

### Machines

| VM | Hostname | IP | RAM | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **Core** | lab-core | `10.10.10.11` | 6 GB | All containers, Ansible, webhook, Tailscale |
| **Target 1** | tgt-01 | `10.10.10.21` | 1 GB | Monitored host |
| **Target 2** | tgt-02 | `10.10.10.22` | 1 GB | Monitored host and SNMP stand-in |

### Ports on lab-core

| Service | Port | Owner |
| :--- | :--- | :--- |
| **Grafana** | `3000` | Goldy (runs in Ahmed's compose file) |
| **Prometheus** | `9090` | Ahmed |
| **Alertmanager** | `9093` | Ahmed |
| **Zabbix web** | `8080` | Terry |
| **Zabbix server** | `10051` | Terry |
| **Nagios web** | `8081` | Pritpal |
| **SMS bridge** | `8088` | Pritpal |
| **Remediation webhook** | `9000` | Malcolm |

> 📌 **On targets:** `node_exporter` (9100), `Zabbix agent` (10050), `NRPE` (5666), `SNMP UDP` (161), `SSH` (22).

---

## Alerting Profile

### Alert Labels
* **severity:** `critical`, `warning`, or `info`
* **remediate:** `disk_cleanup` or `absent`

### Severity Routing

| Severity | Example Scenario | Alerting Channel |
| :--- | :--- | :--- |
| 🔴 **critical** | Host down, disk under 5% free | Email + SMS |
| 🟡 **warning** | Disk under 15% free | Email (and auto-fix if remediate is set) |
| 🔵 **info** | Config change | Dashboard only |

---

## Team Ground Rules
* **Scoped Environments:** Work only in your own folder `/opt/soc/<area>` and your own compose project.
* **Source Control:** Everything goes in Git. Push at least daily. Another person reviews risky changes.
* **Credential Hygiene:** Never commit `secrets/`, `.env` or SSH keys.
* **Data Integrity:** Never run `docker compose down -v` on shared data.
* **Coordination:** Announce in team chat before restarting a VM or the whole stack.
* **System Security:** Change default passwords (Grafana, Zabbix, Nagios) on first login.
