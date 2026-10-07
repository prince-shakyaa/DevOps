# 11 OOMKilled

**Workload:** `marks-cruncher`, which allocates ~200 MiB with a memory limit of 64 MiB.

![broken](../../screenshots/11-oomkilled-broken.png)

- **Symptom:** `OOMKilled`, then `CrashLoopBackOff`.
- **Diagnosis:** `lastState.terminated` gives `reason: OOMKilled, exitCode: 137` (128 + 9,
  meaning SIGKILL). The kernel's OOM killer stopped the process when the cgroup reached its
  limit. There was no error message and no graceful shutdown, so even the `print` before the
  sleep never ran.
- **Fix:** set the limit from the real working set plus headroom (256Mi request / 320Mi
  limit). `kubectl top` afterwards shows **203Mi**, which confirms the size. The other fix is
  to make the app use less memory, for example by streaming instead of loading everything.

![fixed](../../screenshots/11-oomkilled-fixed.png)

CPU limits behave very differently: a container over its CPU limit is **throttled**, never
killed. Memory is the only limit that kills.
