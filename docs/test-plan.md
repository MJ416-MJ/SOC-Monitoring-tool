# SOC Monitoring Project -- Acceptance Test Plan

**Source:** *SOC Monitoring Lab: Team Build Guide*, Sections 12--14\
**Environment:** lab-core, tgt-01 and tgt-02 on the `10.10.10.0/24`
host-only network\
**Document status:** Planned --- tests are **Not Run** until evidence is
captured.

## 1. Purpose

This plan defines the integration checks and seven acceptance tests
specified in the team build guide. The aim is to verify the monitoring
and response chain: a fault is introduced, monitoring detects it, alerts
and notifications are generated, the approved remediation path runs
where applicable, the alert resolves, and Grafana reflects the state.

Do not mark a test as passed based only on a dashboard screenshot.
Capture the evidence specified in Section 5.

## 2. Lab reference

  -----------------------------------------------------------------------
  System            Hostname          IP address        Relevant services
  ----------------- ----------------- ----------------- -----------------
  Core              `lab-core`        `10.10.10.11`     Prometheus
                                                        `9090`,
                                                        Alertmanager
                                                        `9093`, Grafana
                                                        `3000`, Zabbix
                                                        web `8080`,
                                                        Nagios web
                                                        `8081`, SMS
                                                        bridge `8088`,
                                                        remediation
                                                        webhook `9000`

  Target 1          `tgt-01`          `10.10.10.21`     Node Exporter
                                                        `9100`, Zabbix
                                                        agent `10050`,
                                                        NRPE `5666`, SNMP
                                                        UDP `161`, SSH
                                                        `22`

  Target 2          `tgt-02`          `10.10.10.22`     Node Exporter
                                                        `9100`, Zabbix
                                                        agent `10050`,
                                                        NRPE `5666`, SNMP
                                                        UDP `161`, SSH
                                                        `22`
  -----------------------------------------------------------------------

## 3. Test ownership and team responsibilities

**The technical leads run the tests for the components they implemented.
Goldy is the test coordinator and evidence/documentation owner; Goldy is
not expected to execute every test personally.** Acceptance tests that
cross multiple components must be verified jointly: the lead coordinates
the test, and every relevant component owner confirms their part of the
expected result.

  -------------------------------------------------------------------------
  Person                  Project responsibility  Testing and evidence
                                                  responsibility
  ----------------------- ----------------------- -------------------------
  Malcolm                 Host and Automation     Lead host/automation
                          Lead                    tests, VM readiness,
                                                  remediation and webhook
                                                  checks; provide command
                                                  output and remediation
                                                  evidence.

  Ahmed                   Prometheus and          Lead
                          Alertmanager Lead       Prometheus/Alertmanager
                                                  checks; verify metrics,
                                                  alert rules, alert
                                                  firing/resolution and
                                                  routing evidence.

  Terry                   Zabbix and Network Lead Lead Zabbix/network
                                                  checks; verify
                                                  host/problem detection,
                                                  SNMP/network fault
                                                  results and Zabbix
                                                  notification evidence.

  Pritpal                 Notifications and       Verify SMS bridge,
                          Nagios Lead             SMS/fallback logs, Nagios
                                                  host/service status and
                                                  notification evidence for
                                                  relevant tests.

  Goldy                   Grafana, Docs and       Coordinate the test
                          Coordination Lead       schedule, share this
                                                  plan, collect and review
                                                  evidence, maintain test
                                                  status/results, capture
                                                  Grafana evidence, and
                                                  consolidate the final
                                                  report.
  -------------------------------------------------------------------------

### Test ownership matrix

  -----------------------------------------------------------------------
  Acceptance test         Test lead               Required supporting
                                                  verification
  ----------------------- ----------------------- -----------------------
  AT-01 --- Disk fills    Malcolm                 Ahmed: alert/routing;
  and is fixed                                    Pritpal: notification
                                                  path; Goldy: dashboard
                                                  and evidence
                                                  collection.

  AT-02 --- Cleanup       Malcolm                 Ahmed:
  cannot fix it                                   `RemediationFailed`
                                                  alert; Pritpal: email
                                                  and SMS; Goldy:
                                                  evidence collection.

  AT-03 --- Host down     Ahmed                   Terry: Zabbix; Pritpal:
                                                  SMS/Nagios; Malcolm: VM
                                                  power/restore; Goldy:
                                                  dashboard and evidence
                                                  collection.

  AT-04 --- Network fault Terry                   Malcolm: target
                                                  access/restore support;
                                                  Goldy: dashboard and
                                                  evidence collection.

  AT-05 --- Safety gate   Malcolm                 Goldy: record
                                                  request/response and
                                                  rejection evidence.

  AT-06 --- Monitoring    Ahmed                   Terry and/or Pritpal:
  watchdog                                        verify Zabbix or Nagios
                                                  detection; Goldy:
                                                  record
                                                  dashboard/evidence
                                                  where available.

  AT-07 --- Dashboard     Goldy                   Relevant technical lead
                                                  performs or coordinates
                                                  the selected
                                                  fault/test; component
                                                  owners confirm the
                                                  underlying result.
  -----------------------------------------------------------------------

The test lead coordinates execution and ensures every expected outcome
is checked. A test is not passed merely because the lead's own component
worked. For cross-system tests, the required supporting owners must
confirm their results.

### What each test lead must submit to Goldy

For each test, submit:

1.  Test ID and name (for example, `AT-03 — Host down`).
2.  Execution date and start/end time, including timezone.
3.  Names of people who executed or verified the test.
4.  Brief description of actions performed and actual commands used
    where relevant.
5.  Timestamped screenshots or logs showing important stages and
    expected outcomes.
6.  Actual result: **Pass**, **Fail** or **Blocked**, with a short
    explanation.
7.  Any issue encountered, corrective action taken and retest result.
8.  Confirmation that the test environment was restored after the test.

Goldy reviews submissions, requests missing evidence if needed, updates
this test plan and organizes approved evidence in the repository. Test
leads should send original screenshots/logs and test details; they do
not need to edit the master test plan themselves. A test must not be
marked passed until all expected outcomes have been demonstrated.

### Evidence naming and handoff

Use this filename convention:

`AT-<number>-<short-description>-YYYYMMDD-HHMM.<extension>`

Examples: - `AT-01-disk-before-20261118-1430.png` -
`AT-01-alert-firing-20261118-1435.png` -
`AT-01-remediation-log-20261118-1440.txt`

Suggested repository structure:

``` text
docs/
├── test-plan.md
└── evidence/
    ├── AT-01/
    ├── AT-02/
    ├── AT-03/
    ├── AT-04/
    ├── AT-05/
    ├── AT-06/
    └── AT-07/
```

Goldy maintains the evidence folders and final consolidated record. Test
leads send the evidence and results to Goldy through the team's agreed
communication channel.

## 4. Preconditions and safety

Complete the integration sequence in Section 12 of the team guide before
acceptance testing. Stop and resolve a failed integration hop before
proceeding.

-   [ ] Every team laptop can ping `10.10.10.11`; lab-core can ping
    `10.10.10.21`.
-   [ ] From lab-core, `curl http://10.10.10.21:9100/metrics` works.
-   [ ] Prometheus `/targets` shows both targets UP.
-   [ ] Both targets report in Zabbix.
-   [ ] Both targets are green in Nagios.
-   [ ] Grafana panels show live Prometheus and Zabbix data.
-   [ ] An `amtool` test alert arrives by email.
-   [ ] SMS bridge curl test works; a real critical alert sends SMS (or
    the documented fallback log output is demonstrated).
-   [ ] Manual curl to the webhook works, then Alertmanager can trigger
    it.
-   [ ] The team is ready to run the first acceptance test.

**Destructive-test safety:** Take a snapshot of every VM before
destructive tests and roll back afterwards, as required by the guide.
Coordinate before powering off a VM or stopping a shared service. Do not
perform disk-fill, host-down, network-fault or monitoring-stop tests on
the shared lab without the team owner's agreement and a confirmed
rollback plan.

## 5. Evidence standard

For every acceptance test, record: - Test start and end time, including
timezone. - Executor(s) and participating service owners. - Actual
actions and commands used. - Pass, Fail, Blocked or Not Run result. -
Timestamped screenshots of the relevant alert, email or SMS, remediation
log and Grafana panel, as applicable. - Any deviation, error, corrective
action and retest result.

Suggested evidence naming convention:
`TEST-<number>-<evidence>-YYYYMMDD-HHMM.png`.

Do not include passwords, API tokens, `.env` contents, SSH private keys
or other secrets in screenshots or Git.

## 6. Acceptance tests

### AT-01 --- Disk fills and is fixed

**Guide procedure:** On `tgt-01`, check `df -h /`, then use
`fallocate -l <size> /var/fill.img` to leave under 15% free.

**Expected result (guide):** 1. `DiskSpaceLow` fires. 2. Email arrives.
3. Webhook runs cleanup. 4. `/var/fill.img` is removed. 5. Alert
resolves. 6. Remediation log shows `OK`.

**Owners:** Entire team; Malcolm owns remediation, Ahmed owns
alerting/routing, Pritpal owns notification path, Goldy captures
dashboard evidence.

**Evidence to capture:** Before/after disk usage, firing alert, email,
remediation log showing the cleanup and `OK`, resolved alert, Grafana
panel.

**Status:** Not Run\
**Execution timestamp:** \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\
**Executor(s):** \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\
**Actual result / notes:** \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\
**Evidence filenames/links:** \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

### AT-02 --- Cleanup cannot fix it

**Guide procedure:** Fill the disk using a different file name that the
cleanup script does not delete.

**Expected result (guide):** `RemediationFailed` critical alert, email
and SMS.

**Safety:** Requires a VM snapshot and coordinated rollback. Use only
the agreed test file and test window.

**Owners:** Malcolm, Ahmed and Pritpal; Goldy captures evidence.

**Evidence to capture:** Disk usage, `RemediationFailed` alert, email,
SMS (or agreed SMS-bridge fallback log), remediation log and Grafana
panel.

**Status:** Not Run\
**Execution timestamp:** \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\
**Executor(s):** \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\
**Actual result / notes:** \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\
**Evidence filenames/links:** \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

### AT-03 --- Host down

**Guide procedure:** Power off `tgt-02`.

**Expected result (guide):** 1. `HostDown` fires. 2. Email and SMS are
sent. 3. Zabbix and Nagios also show the host down.

**Safety:** Snapshot every VM first; coordinate the power-off and
restore `tgt-02` immediately after evidence capture.

**Owners:** Entire team; Ahmed handles Prometheus/Alertmanager, Terry
Zabbix, Pritpal SMS/Nagios, Malcolm host operations, Goldy
evidence/dashboard.

**Evidence to capture:** `HostDown` alert, email, SMS or fallback log,
Zabbix host state, Nagios host state, Grafana panel, and recovery after
the VM is restored.

**Status:** Not Run\
**Execution timestamp:** \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\
**Executor(s):** \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\
**Actual result / notes:** \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\
**Evidence filenames/links:** \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

### AT-04 --- Network fault

**Guide procedure:** Stop `snmpd` or bring down the interface on
`tgt-02`.

**Expected result (guide):** A Zabbix problem appears and Zabbix sends
an email.

**Safety:** Coordinate with Terry before changing the target network or
SNMP service. Record the original state and restore it after the test.

**Owners:** Terry leads; Malcolm assists with host access; Goldy
captures evidence.

**Evidence to capture:** Fault introduced, Zabbix problem, email
notification, Grafana Zabbix panel, and recovery after restoring the
service/interface.

**Status:** Not Run\
**Execution timestamp:** \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\
**Executor(s):** \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\
**Actual result / notes:** \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\
**Evidence filenames/links:** \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

### AT-05 --- Safety gate

**Guide procedure:** Send the webhook an unknown host or an unknown
action.

**Expected result (guide):** `REJECTED` appears in the remediation log
and nothing runs.

**Safety:** Use only invalid test values. Do not use a valid
target/action combination for this negative test.

**Owners:** Malcolm leads; Goldy records evidence.

**Evidence to capture:** Test request (with no secrets), HTTP response,
corresponding `REJECTED` log entry, and confirmation that no remediation
ran.

**Status:** Not Run\
**Execution timestamp:** \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\
**Executor(s):** \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\
**Actual result / notes:** \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\
**Evidence filenames/links:** \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

### AT-06 --- Monitoring watchdog

**Guide procedure:** Stop the Prometheus container.

**Expected result (guide):** 1. Zabbix or Nagios reports the monitoring
failure. 2. The `Watchdog` stops showing.

**Safety:** This interrupts monitoring. Coordinate with Ahmed and the
team, take/confirm snapshots as required, capture evidence promptly and
restart Prometheus immediately after the test.

**Owners:** Ahmed leads the Prometheus action; Terry/Pritpal verify
Zabbix or Nagios; Goldy captures evidence.

**Evidence to capture:** Prometheus stopped state, Zabbix or Nagios
monitoring-failure indication, Watchdog state, Grafana observation if
available, and restored service after restart.

**Status:** Not Run\
**Execution timestamp:** \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\
**Executor(s):** \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\
**Actual result / notes:** \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\
**Evidence filenames/links:** \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

### AT-07 --- Dashboard

**Guide procedure:** Repeat any acceptance test above.

**Expected result (guide):** Grafana reflects the test live.

**Owners:** Goldy leads dashboard observation; the owner of the repeated
test performs the fault and response steps.

**Evidence to capture:** Timestamped Grafana screenshot showing the
relevant state during the selected test, plus the matching test
evidence.

**Selected test repeated:** \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\
**Status:** Not Run\
**Execution timestamp:** \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\
**Executor(s):** \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\
**Actual result / notes:** \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\
**Evidence filenames/links:** \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

## 7. Test summary

Update this table only after executing each test.

  Test    Description                 Status    Evidence reference
  ------- --------------------------- --------- --------------------
  AT-01   Disk fills and is fixed     Not Run   ---
  AT-02   Cleanup cannot fix it       Not Run   ---
  AT-03   Host down                   Not Run   ---
  AT-04   Network fault               Not Run   ---
  AT-05   Safety gate                 Not Run   ---
  AT-06   Monitoring watchdog         Not Run   ---
  AT-07   Dashboard reflects a test   Not Run   ---

## 8. Completion criteria

The acceptance-test activity is complete when all seven tests have been
executed, their actual outcomes recorded, and timestamped evidence
captured. Any failed or blocked test must include notes explaining the
issue and the retest outcome. Do not report a planned test as passed.

## 9. Source

This plan is based on the *SOC Monitoring Lab: Team Build Guide*,
particularly: - Section 12 --- Integration order. - Section 13 ---
Acceptance tests and snapshot/rollback instruction. - Section 14 ---
Deliverables checklist and 10-minute demo script.

The test procedures and expected outcomes above retain the guide's
acceptance-test wording and scope. Operational cautions in this plan
restate the guide's snapshot, rollback and team-coordination
requirements.
